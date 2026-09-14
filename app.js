const LIKERT_GROUPS = [
  {
    title: "Phòng học & Giảng đường",
    items: [
      { id: "room_space", label: "Diện tích và cách bố trí phòng học" },
      { id: "room_light", label: "Ánh sáng trong phòng học" },
      { id: "room_ac", label: "Hệ thống điều hòa / quạt thông gió" },
      { id: "room_furniture", label: "Bàn ghế, trang thiết bị nội thất" },
      { id: "room_teach_equip", label: "Thiết bị giảng dạy (máy chiếu, âm thanh, bảng)" },
    ],
  },
  {
    title: "Vệ sinh & An toàn",
    items: [
      { id: "toilet", label: "Nhà vệ sinh (sạch sẽ, đầy đủ thiết bị)" },
      { id: "cleanliness", label: "Vệ sinh chung của khu vực" },
      { id: "security", label: "An ninh, bảo vệ" },
      { id: "fire_safety", label: "Hệ thống phòng cháy chữa cháy" },
    ],
  },
  {
    title: "Hạ tầng kỹ thuật",
    items: [
      { id: "wifi", label: "Chất lượng Wifi / mạng internet" },
      { id: "electric_water", label: "Hệ thống điện, nước" },
      { id: "elevator_access", label: "Thang máy, lối đi, khả năng tiếp cận" },
    ],
  },
  {
    title: "Không gian chung",
    items: [
      { id: "canteen", label: "Căng tin (chất lượng, giá cả, vệ sinh)" },
      { id: "library", label: "Thư viện (không gian, tài liệu, tiện nghi)" },
      { id: "self_study", label: "Khu tự học / không gian sinh hoạt chung" },
      { id: "campus_scenery", label: "Cảnh quan, cây xanh sân trường" },
      { id: "sports", label: "Nhà thi đấu / khu vực thể thao" },
    ],
  },
];

const LIKERT_LABELS = [
  "Rất không hài lòng",
  "Không hài lòng",
  "Bình thường",
  "Hài lòng",
  "Rất hài lòng",
];

const OVERALL_OPTIONS = [
  { value: "1", emoji: "😞", txt: "Rất tệ" },
  { value: "2", emoji: "🙁", txt: "Tệ" },
  { value: "3", emoji: "😐", txt: "Bình thường" },
  { value: "4", emoji: "🙂", txt: "Tốt" },
  { value: "5", emoji: "😄", txt: "Rất tốt" },
];

const STORAGE_KEY = "vku_survey_records_v1";
const SERVER_HISTORY_CACHE_KEY = "vku_survey_server_history_v1";
const SYNC_URL_KEY = "vku_survey_sync_url_v1";
const SYNC_INCLUDE_PHOTO_KEY = "vku_survey_sync_photo_v1";

const DEFAULT_SYNC_URL =
  "https://script.google.com/macros/s/AKfycbwzQZ99pbyexCV4Fxxy5PWuKp1-8oQKHWxt7MjkaF_RefjcK0zAbO1L_Qx-z5X-_p1b/exec";

const PHOTO_MAX_WIDTH = 900;
const PHOTO_JPEG_QUALITY = 0.6;

const GEO_TIMEOUT_MS = 10000;
const HISTORY_TIMEOUT_MS = 8000;

let toastTimer = null;
let photoDataUrl = null;
let geoLocation = null;
let currentDisplayRecords = [];
let isSyncing = false;
let historyRequestInProgress = false;

// ======================================================
// UI
// ======================================================

function showToast(msg) {
  const toast = document.getElementById("toast");
  if (!toast) return;
  toast.textContent = msg;
  toast.classList.add("show");
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => toast.classList.remove("show"), 2600);
}

function updateNetStatus() {
  const dot = document.getElementById("netDot");
  const label = document.getElementById("netLabel");
  if (!dot || !label) return;

  if (navigator.onLine) {
    dot.className = "dot online";
    label.textContent = "Đang trực tuyến";
  } else {
    dot.className = "dot offline";
    label.textContent = "Ngoại tuyến — dữ liệu lưu cục bộ";
  }
}

window.addEventListener("online", () => {
  updateNetStatus();
  // Khi có mạng trở lại thì đồng bộ ngầm.
  syncRecords({ silent: true });
});
window.addEventListener("offline", updateNetStatus);

// ======================================================
// TAB
// ======================================================

function initTabs() {
  const tabs = document.querySelectorAll(".tab");
  tabs.forEach((tab) => {
    tab.addEventListener("click", () => {
      tabs.forEach((t) => {
        t.classList.remove("active");
        t.setAttribute("aria-selected", "false");
      });
      tab.classList.add("active");
      tab.setAttribute("aria-selected", "true");

      document.querySelectorAll(".panel").forEach((p) => p.classList.remove("active"));
      const panel = document.getElementById(`tab-${tab.dataset.tab}`);
      if (panel) panel.classList.add("active");

      if (tab.dataset.tab === "queue") renderQueue();
    });
  });
}

// ======================================================
// LIKERT
// ======================================================

function renderLikertGroups() {
  const container = document.getElementById("likertGroups");
  if (!container) return;

  container.innerHTML = LIKERT_GROUPS.map(
    (group) => `
      <div class="likert-group">
        <h3 class="likert-group-title">${group.title}</h3>
        ${group.items
          .map(
            (item) => `
              <div class="likert-item">
                <div class="likert-item-label">${item.label}</div>
                <div class="likert-scale" role="radiogroup" aria-label="${item.label}">
                  ${[1, 2, 3, 4, 5]
                    .map(
                      (val) => `
                        <div class="likert-option">
                          <input type="radio" name="likert_${item.id}" id="likert_${item.id}_${val}" value="${val}" required />
                          <label for="likert_${item.id}_${val}">
                            <span class="num">${val}</span>
                            <span class="txt">${LIKERT_LABELS[val - 1].split("\n")[0]}</span>
                          </label>
                        </div>
                      `
                    )
                    .join("")}
                </div>
              </div>
            `
          )
          .join("")}
      </div>
    `
  ).join("");
}

function renderOverallScale() {
  const container = document.getElementById("overallScale");
  if (!container) return;

  container.innerHTML = OVERALL_OPTIONS.map(
    (opt) => `
      <div class="overall-option">
        <input type="radio" name="overallScore" id="overall_${opt.value}" value="${opt.value}" required />
        <label for="overall_${opt.value}">
          <span class="emoji">${opt.emoji}</span>
          <span class="txt">${opt.txt}</span>
        </label>
      </div>
    `
  ).join("");
}

// ======================================================
// LOCAL STORAGE
// ======================================================

function getRecords() {
  try {
    const data = JSON.parse(localStorage.getItem(STORAGE_KEY));
    return Array.isArray(data) ? data : [];
  } catch {
    return [];
  }
}

function saveRecords(records) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(records));
    updateQueueBadge();
    return true;
  } catch (err) {
    console.error("Lưu localStorage thất bại:", err);
    return false;
  }
}

function updateQueueBadge(records = null) {
  const count = records ? records.length : getRecords().length;
  const badge = document.getElementById("queueCount");
  if (badge) badge.textContent = count;
}

// ======================================================
// PHOTO
// ======================================================

function compressImage(file, maxWidth = PHOTO_MAX_WIDTH, quality = PHOTO_JPEG_QUALITY) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();

    reader.onload = (e) => {
      const img = new Image();

      img.onload = () => {
        try {
          let width = img.width;
          let height = img.height;

          if (width > maxWidth) {
            height = Math.round((height * maxWidth) / width);
            width = maxWidth;
          }

          const canvas = document.createElement("canvas");
          canvas.width = width;
          canvas.height = height;

          const ctx = canvas.getContext("2d");
          ctx.drawImage(img, 0, 0, width, height);

          resolve(canvas.toDataURL("image/jpeg", quality));
        } catch (err) {
          reject(err);
        }
      };

      img.onerror = () => reject(new Error("Không đọc được ảnh"));
      img.src = e.target.result;
    };

    reader.onerror = () => reject(new Error("Không đọc được file ảnh"));
    reader.readAsDataURL(file);
  });
}

function withTimeout(promise, ms, message) {
  return Promise.race([
    promise,
    new Promise((_, reject) => setTimeout(() => reject(new Error(message)), ms)),
  ]);
}

function initPhotoInput() {
  const input = document.getElementById("photo");
  const preview = document.getElementById("photoPreview");
  if (!input) return;

  input.addEventListener("change", () => {
    const file = input.files[0];

    if (!file) {
      photoDataUrl = null;
      if (preview) preview.hidden = true;
      return;
    }

    showToast("Đang xử lý ảnh…");

    withTimeout(compressImage(file), 8000, "Xử lý ảnh quá lâu")
      .then((dataUrl) => {
        photoDataUrl = dataUrl;
        if (preview) {
          preview.src = photoDataUrl;
          preview.hidden = false;
        }
        showToast("Đã xử lý ảnh ✅");
      })
      .catch((err) => {
        console.error(err);
        showToast("Không xử lý được ảnh này");
        photoDataUrl = null;
        if (preview) preview.hidden = true;
        input.value = "";
      });
  });
}

// ======================================================
// GPS
// ======================================================

function renderGeoStatus() {
  const statusEl = document.getElementById("geoStatus");
  const clearBtn = document.getElementById("geoClearBtn");
  if (!statusEl) return;

  if (geoLocation) {
    const coordsText = `${geoLocation.lat.toFixed(5)}, ${geoLocation.lng.toFixed(5)} (±${Math.round(geoLocation.accuracy)}m)`;

    if (geoLocation.address) {
      statusEl.textContent = `📍 ${geoLocation.address} (${coordsText})`;
    } else if (navigator.onLine) {
      statusEl.textContent = `📍 ${coordsText} — đang tra tên địa điểm…`;
    } else {
      statusEl.textContent = `📍 ${coordsText} (ngoại tuyến)`;
    }

    statusEl.classList.add("geo-ok");
    if (clearBtn) clearBtn.hidden = false;
  } else {
    statusEl.textContent = "Chưa lấy vị trí GPS";
    statusEl.classList.remove("geo-ok");
    if (clearBtn) clearBtn.hidden = true;
  }
}

function fetchAddressForGeo() {
  if (!geoLocation || !navigator.onLine) return;

  const { lat, lng } = geoLocation;
  const url =
    `https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${lat}&lon=${lng}&zoom=17&addressdetails=1`;

  withTimeout(
    fetch(url, { headers: { Accept: "application/json" } }),
    8000,
    "Tra cứu tên địa điểm quá lâu"
  )
    .then((res) => {
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      return res.json();
    })
    .then((data) => {
      if (geoLocation && geoLocation.lat === lat && geoLocation.lng === lng && data && data.display_name) {
        geoLocation.address = data.display_name;
        renderGeoStatus();
      }
    })
    .catch((err) => console.warn("Không tra được tên địa điểm:", err));
}

function initGeoInput() {
  const btn = document.getElementById("geoBtn");
  const clearBtn = document.getElementById("geoClearBtn");
  if (!btn) return;

  renderGeoStatus();

  btn.addEventListener("click", () => {
    if (!("geolocation" in navigator)) {
      showToast("Thiết bị không hỗ trợ định vị GPS");
      return;
    }

    btn.disabled = true;
    const originalLabel = btn.textContent;
    btn.textContent = "Đang lấy vị trí…";

    navigator.geolocation.getCurrentPosition(
      (pos) => {
        geoLocation = {
          lat: pos.coords.latitude,
          lng: pos.coords.longitude,
          accuracy: pos.coords.accuracy,
          capturedAt: new Date().toISOString(),
          address: null,
        };

        renderGeoStatus();
        showToast("Đã lấy vị trí GPS ✅");

        btn.disabled = false;
        btn.textContent = originalLabel;

        fetchAddressForGeo();
      },

      (err) => {
        btn.disabled = false;
        btn.textContent = originalLabel;

        let msg = "Không lấy được vị trí GPS";
        if (err.code === err.PERMISSION_DENIED) msg = "Bạn đã từ chối quyền truy cập vị trí";
        else if (err.code === err.POSITION_UNAVAILABLE) msg = "Không xác định được vị trí hiện tại";
        else if (err.code === err.TIMEOUT) msg = "Lấy vị trí quá lâu, thử lại";

        showToast(msg);
      },

      { enableHighAccuracy: true, timeout: GEO_TIMEOUT_MS, maximumAge: 0 }
    );
  });

  if (clearBtn) {
    clearBtn.addEventListener("click", () => {
      geoLocation = null;
      renderGeoStatus();
    });
  }
}

// ======================================================
// FORM
// ======================================================

function collectLikertAnswers() {
  const answers = {};
  LIKERT_GROUPS.forEach((group) => {
    group.items.forEach((item) => {
      const checked = document.querySelector(`input[name="likert_${item.id}"]:checked`);
      answers[item.id] = checked ? Number(checked.value) : null;
    });
  });
  return answers;
}

function initForm() {
  const form = document.getElementById("surveyForm");
  if (!form) return;

  form.addEventListener("submit", (e) => {
    e.preventDefault();

    if (!form.checkValidity()) {
      form.reportValidity();
      return;
    }

    const overallChecked = document.querySelector('input[name="overallScore"]:checked');
    if (!overallChecked) {
      showToast("Vui lòng chọn mức độ hài lòng chung");
      return;
    }

    const record = {
      id: `rec_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`,
      createdAt: new Date().toISOString(),
      synced: false,

      respondent: {
        fullname: document.getElementById("fullname").value.trim(),
        studentId: document.getElementById("studentId").value.trim(),
        email: document.getElementById("email").value.trim(),
        className: document.getElementById("className").value.trim(),
        faculty: document.getElementById("faculty").value || null,
        role: document.getElementById("role").value,
      },

      location: {
        building: document.getElementById("building").value,
        room: document.getElementById("room").value.trim(),
        geo: geoLocation,
      },

      likert: collectLikertAnswers(),
      overallScore: Number(overallChecked.value),
      recommend: document.getElementById("recommend").value || null,
      notes: document.getElementById("notes").value.trim(),
      photo: photoDataUrl,
    };

    const records = getRecords();
    records.unshift(record);

    const ok = saveRecords(records);
    if (!ok) {
      records.shift();
      showToast("Không lưu được — bộ nhớ đầy. Thử bỏ ảnh hoặc xoá khảo sát cũ.");
      return;
    }

    showToast(navigator.onLine ? "Đã lưu khảo sát, đang đồng bộ…" : "Đã lưu khảo sát vào máy ✅");

    form.reset();

    const photoPreview = document.getElementById("photoPreview");
    if (photoPreview) photoPreview.hidden = true;

    photoDataUrl = null;
    geoLocation = null;
    renderGeoStatus();

    window.scrollTo({ top: 0, behavior: "smooth" });

    // Đồng bộ nền.
    if (navigator.onLine) syncRecords({ silent: false });
  });
}

// ======================================================
// DATE
// ======================================================

function fmtDate(iso) {
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "—";

  return d.toLocaleString("vi-VN", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

// ======================================================
// PHOTO DISPLAY
// ======================================================

function renderPhotoBlock(photo, cssClass) {
  if (!photo) return "";

  const str = String(photo);

  if (str.startsWith("data:image")) {
    return `<img class="${cssClass}" src="${str}" alt="Ảnh khảo sát" />`;
  }

  if (str.startsWith("http")) {
    return `
      <a href="${str}" target="_blank" rel="noopener" style="display:inline-block;margin-top:6px;color:#1f4b99;font-weight:600;">
        📎 Xem ảnh đính kèm
      </a>
    `;
  }

  return "";
}

// ======================================================
// QUEUE / HISTORY
// ======================================================

function renderQueueList(records) {
  currentDisplayRecords = Array.isArray(records) ? records : [];

  const list = document.getElementById("recordList");
  const empty = document.getElementById("emptyState");
  if (!list || !empty) return;

  if (currentDisplayRecords.length === 0) {
    list.innerHTML = "";
    empty.classList.add("show");
    return;
  }

  empty.classList.remove("show");

  list.innerHTML = currentDisplayRecords
    .map((r) => {
      const geo = r.location && r.location.geo;
      const locationText = geo
        ? geo.address || `${Number(geo.lat).toFixed(5)}, ${Number(geo.lng).toFixed(5)}`
        : "";

      return `
        <li class="record-item" data-id="${escapeHtml(r.id)}" style="cursor:pointer;">
          <div class="record-head">
            <div>
              <div class="record-title">
                ${escapeHtml(r.location?.building || "—")}
                ${r.location?.room ? " · " + escapeHtml(r.location.room) : ""}
              </div>
              <div class="record-sub">
                ${escapeHtml(r.respondent?.fullname || "Ẩn danh")}
                ·
                ${escapeHtml(r.respondent?.studentId || "—")}
              </div>
            </div>

            <span class="record-status ${r.synced ? "synced" : "pending"}">
              ${r.synced ? "Đã đồng bộ" : "Chờ đồng bộ"}
            </span>
          </div>

          <div class="record-meta">
            <span>🕒 ${fmtDate(r.createdAt)}</span>
            <span>⭐ Tổng thể: ${r.overallScore ?? "—"}/5</span>
            <span>📧 ${escapeHtml(r.respondent?.email || "—")}</span>
            ${locationText ? `<span>📍 ${escapeHtml(locationText)}</span>` : ""}
            ${!r._isLocal ? `<span>☁️ Từ Google Sheet</span>` : ""}
          </div>

          ${renderPhotoBlock(r.photo, "record-photo")}

          <div class="record-actions">
            ${r._isLocal ? `<button data-action="delete">Xoá</button>` : ""}
          </div>
        </li>
      `;
    })
    .join("");

  // Xoá bản ghi local.
  list.querySelectorAll('[data-action="delete"]').forEach((btn) => {
    btn.addEventListener("click", (e) => {
      e.stopPropagation();

      const item = e.target.closest(".record-item");
      if (!item) return;

      const id = item.dataset.id;
      const updated = getRecords().filter((r) => r.id !== id);

      saveRecords(updated);
      renderQueue();
    });
  });

  // Mở chi tiết.
  list.querySelectorAll(".record-item").forEach((li) => {
    li.addEventListener("click", () => {
      const id = li.dataset.id;
      const record = currentDisplayRecords.find((r) => String(r.id) === String(id));
      if (record) openRecordDetail(record);
    });
  });
}

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

// ======================================================
// REMOTE GOOGLE SHEET
// ======================================================

function remoteRowToRecord(row) {
  let likert = {};
  try {
    likert = JSON.parse(row.likertJSON || "{}");
  } catch {
    likert = {};
  }

  const hasGeo = row.geoLat !== "" && row.geoLat !== undefined && row.geoLat !== null;

  return {
    id: row.id,
    createdAt: row.createdAt,
    synced: true,
    _isLocal: false,

    respondent: {
      fullname: row.fullname || "",
      studentId: row.studentId || "",
      email: row.email || "",
      className: row.className || "",
      faculty: row.faculty || "",
      role: row.role || "",
    },

    location: {
      building: row.building || "",
      room: row.room || "",
      geo: hasGeo
        ? {
            lat: Number(row.geoLat),
            lng: Number(row.geoLng),
            accuracy: Number(row.geoAccuracy) || 0,
            address: row.geoAddress || "",
          }
        : null,
    },

    likert,
    overallScore: row.overallScore === "" ? null : Number(row.overallScore),
    recommend: row.recommend || null,
    notes: row.notes || "",
    photo: row.photo || null,
  };
}

// ======================================================
// JSONP
// ======================================================

function fetchServerHistoryJsonp(url) {
  return new Promise((resolve) => {
    const callbackName = "vkuHistoryCb_" + Date.now() + "_" + Math.floor(Math.random() * 1e6);
    let finished = false;

    const script = document.createElement("script");
    const timeoutId = setTimeout(() => finish(null), HISTORY_TIMEOUT_MS);

    function cleanup() {
      clearTimeout(timeoutId);
      delete window[callbackName];
      if (script.parentNode) script.parentNode.removeChild(script);
    }

    function finish(data) {
      if (finished) return;
      finished = true;
      cleanup();
      resolve(data);
    }

    window[callbackName] = (data) => {
      if (data && data.result === "ok" && Array.isArray(data.records)) {
        finish(data.records);
      } else {
        finish(null);
      }
    };

    const sep = url.includes("?") ? "&" : "?";
    script.src = `${url}${sep}action=list&callback=${callbackName}&_=${Date.now()}`;
    script.onerror = () => finish(null);

    document.body.appendChild(script);
  });
}

// ======================================================
// CACHE SERVER HISTORY
// ======================================================

function getServerHistoryCache() {
  try {
    const data = JSON.parse(localStorage.getItem(SERVER_HISTORY_CACHE_KEY));
    return Array.isArray(data) ? data : [];
  } catch {
    return [];
  }
}

function saveServerHistoryCache(records) {
  try {
    localStorage.setItem(SERVER_HISTORY_CACHE_KEY, JSON.stringify(records));
  } catch (err) {
    console.warn("Không lưu được cache lịch sử:", err);
  }
}

// ======================================================
// MERGE LOCAL + SERVER
// ======================================================

function mergeRecordsForDisplay(localRecords, remoteRecords) {
  const map = new Map();

  remoteRecords.forEach((r) => {
    if (r && r.id) map.set(String(r.id), r);
  });

  localRecords.forEach((r) => {
    if (!r || !r.id) return;
    const key = String(r.id);
    map.set(key, { ...r, synced: map.has(key) ? true : r.synced, _isLocal: true });
  });

  return Array.from(map.values()).sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
}

// ======================================================
// RENDER QUEUE
// ======================================================

function renderQueue() {
  const localRecords = getRecords();
  const cachedRemote = getServerHistoryCache();

  // Hiện local + cache ngay, không đợi Google Sheet.
  const initialRecords = mergeRecordsForDisplay(
    localRecords.map((r) => ({ ...r, _isLocal: true })),
    cachedRemote
  );

  renderQueueList(initialRecords);
  updateQueueBadge(initialRecords);

  // Nếu đang có request thì không gọi thêm.
  if (historyRequestInProgress) return;
  if (!navigator.onLine) return;

  const url = getSyncUrl();
  if (!url) return;

  historyRequestInProgress = true;

  fetchServerHistoryJsonp(url)
    .then((remoteRows) => {
      if (!Array.isArray(remoteRows)) return;

      const remoteRecords = remoteRows.map(remoteRowToRecord);
      saveServerHistoryCache(remoteRecords);

      const latestLocal = getRecords();
      const merged = mergeRecordsForDisplay(
        latestLocal.map((r) => ({ ...r, _isLocal: true })),
        remoteRecords
      );

      // Chỉ cập nhật nếu tab vẫn đang là "Đã lưu".
      const queuePanel = document.getElementById("tab-queue");
      if (queuePanel && queuePanel.classList.contains("active")) {
        renderQueueList(merged);
        updateQueueBadge(merged);
      }
    })
    .catch((err) => console.warn("Không tải được lịch sử Google Sheet:", err))
    .finally(() => {
      historyRequestInProgress = false;
    });
}

// ======================================================
// FETCH SERVER HISTORY
// ======================================================

function fetchServerHistory() {
  const url = getSyncUrl();
  if (!url || !navigator.onLine) return Promise.resolve(null);

  return fetchServerHistoryJsonp(url).then((rawRecords) => {
    if (!rawRecords) return null;
    return rawRecords.map(remoteRowToRecord);
  });
}

// ======================================================
// DETAIL MODAL
// ======================================================

function buildLikertDetailHtml(likertAnswers) {
  return LIKERT_GROUPS.map(
    (group) => `
      <div style="margin-bottom:14px;">
        <div style="font-weight:600;color:#1f4b99;margin-bottom:6px;font-size:14px;">
          ${group.title}
        </div>

        ${group.items
          .map((item) => {
            const val = likertAnswers ? likertAnswers[item.id] : null;
            const labelText = val ? LIKERT_LABELS[val - 1].replace("\n", " ") : null;

            return `
              <div style="display:flex;justify-content:space-between;gap:12px;padding:6px 0;border-bottom:1px solid #eee;font-size:13.5px;">
                <span style="flex:1;">${item.label}</span>
                <span style="font-weight:600;white-space:nowrap;">
                  ${val ? `${val}/5 · ${labelText}` : "—"}
                </span>
              </div>
            `;
          })
          .join("")}
      </div>
    `
  ).join("");
}

function buildRecordDetailHtml(r) {
  const geo = r.location && r.location.geo;

  const geoText = geo
    ? `${geo.address ? geo.address + " — " : ""}${Number(geo.lat).toFixed(5)}, ${Number(geo.lng).toFixed(5)} (±${Math.round(Number(geo.accuracy) || 0)}m)`
    : "Không có";

  const safeNotes = r.notes ? escapeHtml(r.notes) : "—";

  return `
    <div style="font-size:14px;line-height:1.55;color:#222;">
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;">
        <span style="font-weight:700;font-size:16px;">Chi tiết khảo sát</span>
        <span class="record-status ${r.synced ? "synced" : "pending"}">
          ${r.synced ? "Đã đồng bộ" : "Chờ đồng bộ"}
        </span>
      </div>

      <p style="margin:2px 0;color:#666;font-size:13px;">🕒 ${fmtDate(r.createdAt)}</p>

      <h3 style="margin:16px 0 6px;color:#1f4b99;font-size:15px;">Thông tin người khảo sát</h3>
      <p><b>Họ và tên:</b> ${escapeHtml(r.respondent?.fullname || "—")}</p>
      <p><b>Mã số sinh viên:</b> ${escapeHtml(r.respondent?.studentId || "—")}</p>
      <p><b>Email:</b> ${escapeHtml(r.respondent?.email || "—")}</p>
      <p><b>Lớp:</b> ${escapeHtml(r.respondent?.className || "—")}</p>
      <p><b>Khoa/Viện:</b> ${escapeHtml(r.respondent?.faculty || "—")}</p>
      <p><b>Vai trò:</b> ${escapeHtml(r.respondent?.role || "—")}</p>

      <h3 style="margin:16px 0 6px;color:#1f4b99;font-size:15px;">Vị trí khảo sát</h3>
      <p><b>Tòa nhà/Khu vực:</b> ${escapeHtml(r.location?.building || "—")}</p>
      <p><b>Phòng/Vị trí cụ thể:</b> ${escapeHtml(r.location?.room || "—")}</p>
      <p><b>GPS:</b> ${escapeHtml(geoText)}</p>

      <h3 style="margin:16px 0 6px;color:#1f4b99;font-size:15px;">Đánh giá mức độ hài lòng</h3>
      ${buildLikertDetailHtml(r.likert)}

      <h3 style="margin:16px 0 6px;color:#1f4b99;font-size:15px;">Đánh giá tổng thể</h3>
      <p><b>Mức độ hài lòng chung:</b> ${r.overallScore ?? "—"}/5</p>
      <p><b>Sẵn sàng giới thiệu:</b> ${escapeHtml(r.recommend || "—")}</p>
      <p><b>Góp ý / mô tả chi tiết:</b> ${safeNotes}</p>

      ${
        r.photo
          ? `
            <h3 style="margin:16px 0 6px;color:#1f4b99;font-size:15px;">Ảnh minh họa</h3>
            ${
              String(r.photo).startsWith("data:image")
                ? `<img src="${r.photo}" alt="Ảnh khảo sát" style="max-width:100%;border-radius:10px;display:block;" />`
                : `<a href="${r.photo}" target="_blank" rel="noopener" style="color:#1f4b99;font-weight:600;">📎 Mở ảnh</a>`
            }
          `
          : ""
      }
    </div>
  `;
}

function initRecordDetailModal() {
  if (document.getElementById("recordDetailModal")) return;

  const modal = document.createElement("div");
  modal.id = "recordDetailModal";
  modal.style.cssText = `
    display:none;position:fixed;inset:0;background:rgba(0,0,0,0.55);z-index:1000;
    align-items:flex-start;justify-content:center;padding:24px 16px;overflow-y:auto;
  `;

  modal.innerHTML = `
    <div style="background:#fff;border-radius:14px;max-width:560px;width:100%;padding:20px;position:relative;box-shadow:0 10px 40px rgba(0,0,0,0.25);">
      <button id="recordDetailCloseBtn" aria-label="Đóng" style="position:absolute;top:10px;right:10px;background:#f1f1f1;border:none;width:32px;height:32px;border-radius:50%;font-size:18px;cursor:pointer;color:#444;line-height:1;">✕</button>
      <div id="recordDetailBody"></div>
    </div>
  `;

  document.body.appendChild(modal);

  modal.addEventListener("click", (e) => {
    if (e.target === modal) closeRecordDetail();
  });

  document.getElementById("recordDetailCloseBtn").addEventListener("click", closeRecordDetail);

  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") closeRecordDetail();
  });
}

function openRecordDetail(record) {
  const body = document.getElementById("recordDetailBody");
  const modal = document.getElementById("recordDetailModal");
  if (!body || !modal) return;

  body.innerHTML = buildRecordDetailHtml(record);
  modal.style.display = "flex";
  document.body.style.overflow = "hidden";
}

function closeRecordDetail() {
  const modal = document.getElementById("recordDetailModal");
  if (modal) modal.style.display = "none";
  document.body.style.overflow = "";
}

// ======================================================
// GOOGLE SHEET CONFIG
// ======================================================

function getSyncUrl() {
  const stored = (localStorage.getItem(SYNC_URL_KEY) || "").trim();
  return stored || DEFAULT_SYNC_URL.trim();
}

function setSyncUrl(url) {
  localStorage.setItem(SYNC_URL_KEY, url.trim());
}

function getIncludePhotoPref() {
  return localStorage.getItem(SYNC_INCLUDE_PHOTO_KEY) === "1";
}

function setIncludePhotoPref(val) {
  localStorage.setItem(SYNC_INCLUDE_PHOTO_KEY, val ? "1" : "0");
}

// ======================================================
// PAYLOAD
// ======================================================

function recordToSyncPayload(r, includePhoto) {
  return {
    id: r.id,
    createdAt: r.createdAt,
    fullname: r.respondent.fullname,
    studentId: r.respondent.studentId,
    email: r.respondent.email,
    className: r.respondent.className,
    faculty: r.respondent.faculty,
    role: r.respondent.role,
    building: r.location.building,
    room: r.location.room,
    geoLat: r.location.geo ? r.location.geo.lat : "",
    geoLng: r.location.geo ? r.location.geo.lng : "",
    geoAccuracy: r.location.geo ? r.location.geo.accuracy : "",
    geoAddress: r.location.geo ? r.location.geo.address || "" : "",
    likert: r.likert,
    overallScore: r.overallScore,
    recommend: r.recommend,
    notes: r.notes,
    // Gửi ảnh lên Apps Script. Apps Script sẽ lưu ảnh vào Google Drive
    // và trả/lưu URL vào Google Sheet.
    photo: includePhoto ? r.photo : null,
  };
}

// ======================================================
// POST GOOGLE SHEET
// ======================================================

function postRecordToSheet(url, payload) {
  return withTimeout(
    fetch(url, {
      method: "POST",
      mode: "no-cors",
      headers: { "Content-Type": "text/plain;charset=utf-8" },
      body: JSON.stringify(payload),
    }).then(() => ({ result: "ok" })),
    20000,
    "Đồng bộ quá thời gian chờ"
  );
}

// ======================================================
// SYNC
// ======================================================

async function syncRecords({ silent = false } = {}) {
  const url = getSyncUrl();

  if (!url) {
    if (!silent) showToast('Chưa cấu hình Google Sheet');
    return;
  }

  if (!navigator.onLine) {
    if (!silent) showToast("Không có kết nối mạng");
    return;
  }

  if (isSyncing) return;

  const pending = getRecords().filter((r) => !r.synced);

  if (pending.length === 0) {
    if (!silent) showToast("Không có bản ghi cần đồng bộ");
    renderQueue(); // Vẫn tải history mới.
    return;
  }

  isSyncing = true;

  const includePhoto = getIncludePhotoPref();
  let successCount = 0;
  let failCount = 0;

  for (const record of pending) {
    try {
      const payload = recordToSyncPayload(record, includePhoto);
      await postRecordToSheet(url, payload);

      const all = getRecords();
      const idx = all.findIndex((r) => r.id === record.id);

      if (idx !== -1) {
        all[idx].synced = true;
        saveRecords(all);
      }

      successCount++;
    } catch (err) {
      console.error("Đồng bộ thất bại:", record.id, err);
      failCount++;
    }
  }

  isSyncing = false;

  renderQueue(); // Tải lại lịch sử server sau sync.

  if (successCount > 0 && failCount === 0) {
    showToast(`Đã đồng bộ ${successCount} khảo sát lên Google Sheet ✅`);
  } else if (successCount > 0 && failCount > 0) {
    showToast(`Đã đồng bộ ${successCount}, còn ${failCount} lỗi`);
  } else if (failCount > 0) {
    showToast(`Đồng bộ thất bại (${failCount})`);
  }
}

// ======================================================
// SYNC SETTINGS
// ======================================================

function initSyncSettings() {
  const urlInput = document.getElementById("syncUrl");
  const photoCheckbox = document.getElementById("syncIncludePhoto");
  const saveBtn = document.getElementById("syncUrlSaveBtn");

  if (!urlInput || !saveBtn) return;

  urlInput.value = (localStorage.getItem(SYNC_URL_KEY) || "").trim();

  if (!urlInput.value && DEFAULT_SYNC_URL) {
    urlInput.placeholder = "Đang dùng link mặc định trong code";
  }

  if (photoCheckbox) photoCheckbox.checked = getIncludePhotoPref();

  saveBtn.addEventListener("click", () => {
    const url = urlInput.value.trim();

    if (url && !/^https:\/\/script\.google(usercontent)?\.com\//.test(url)) {
      showToast("Link Google Apps Script có vẻ không hợp lệ");
      return;
    }

    setSyncUrl(url);
    if (photoCheckbox) setIncludePhotoPref(photoCheckbox.checked);

    showToast(url ? "Đã lưu cấu hình đồng bộ ✅" : "Đã xoá liên kết đồng bộ");
  });
}

// ======================================================
// QUEUE BUTTONS
// ======================================================

function initQueueActions() {
  const syncBtn = document.getElementById("syncBtn");
  if (syncBtn) {
    syncBtn.addEventListener("click", () => syncRecords({ silent: false }));
  }

  const exportBtn = document.getElementById("exportBtn");
  if (exportBtn) {
    exportBtn.addEventListener("click", () => {
      const records = getRecords();

      if (records.length === 0) {
        showToast("Chưa có dữ liệu để xuất");
        return;
      }

      const blob = new Blob([JSON.stringify(records, null, 2)], { type: "application/json" });
      const url = URL.createObjectURL(blob);

      const a = document.createElement("a");
      a.href = url;
      a.download = `vku_khaosat_${Date.now()}.json`;
      a.click();

      URL.revokeObjectURL(url);
    });
  }

  const clearBtn = document.getElementById("clearSyncedBtn");
  if (clearBtn) {
    clearBtn.addEventListener("click", () => {
      const records = getRecords().filter((r) => !r.synced);
      saveRecords(records);
      renderQueue();
      showToast("Đã xoá các bản ghi đã đồng bộ");
    });
  }
}

// ======================================================
// INIT
// ======================================================

document.addEventListener("DOMContentLoaded", () => {
  renderLikertGroups();
  renderOverallScale();
  initTabs();
  initForm();
  initPhotoInput();
  initGeoInput();
  initSyncSettings();
  initQueueActions();
  initRecordDetailModal();
  updateNetStatus();
  updateQueueBadge();

  // Nếu có mạng, đồng bộ ngầm.
  if (navigator.onLine) syncRecords({ silent: true });
});

// ======================================================
// SERVICE WORKER
// ======================================================

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("service-worker.js").catch((err) => {
      console.warn("Không đăng ký được service worker:", err);
    });
  });
}