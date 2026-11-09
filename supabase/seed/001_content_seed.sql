-- V-STUDY content seed. Run after both migrations.
-- Create admin@vku.udn.vn in Supabase Auth first, then set the variable below
-- to that verified email. This script never stores an admin password in Git.

do $$
declare
  admin_email text := 'admin@vku.udn.vn';
begin
  if not exists (select 1 from auth.users where lower(email) = lower(admin_email)) then
    raise notice 'Create % in Supabase Auth, verify it, then rerun this seed.', admin_email;
  else
    update public.profiles
    set role = 'ADMIN', is_locked = false, updated_at = now()
    where id = (select id from auth.users where lower(email) = lower(admin_email) limit 1);
  end if;
end $$;

insert into public.subjects (code, name, description, credits)
values
  ('TRIET', 'Triết học', 'Triết học Mác - Lênin và các vấn đề nhận thức, xã hội.', 3),
  ('PLDC', 'Pháp luật đại cương', 'Nhà nước, pháp luật và các ngành luật cơ bản.', 2)
on conflict (code) do update set name = excluded.name, description = excluded.description, credits = excluded.credits;

insert into public.quizzes (subject_id, title, description, duration_minutes, is_published, created_by)
select s.id, x.title, x.description, 30, true,
       (select p.id from public.profiles p where p.role = 'ADMIN' order by p.created_at limit 1)
from (values
  ('TRIET', 'Ôn tập Triết học', 'Bộ câu hỏi ôn tập Triết học.'),
  ('PLDC', 'Ôn tập Pháp luật đại cương', 'Bộ câu hỏi ôn tập Pháp luật đại cương.')
) as x(code, title, description)
join public.subjects s on s.code = x.code
where not exists (select 1 from public.quizzes q where q.subject_id = s.id and q.title = x.title);

create temporary table _question_seed (
  code text not null,
  question_text text not null,
  options jsonb not null,
  correct_index smallint not null,
  explanation text not null
) on commit drop;

insert into _question_seed values
('TRIET','Vấn đề cơ bản của triết học là gì?', '["Quan hệ giữa vật chất và ý thức","Quan hệ giữa cá nhân và xã hội","Nguồn gốc của nhà nước","Cấu trúc của ngôn ngữ"]',0,'Vấn đề cơ bản của triết học là quan hệ giữa vật chất và ý thức, gồm mặt bản thể luận và nhận thức luận.'),
('TRIET','Theo chủ nghĩa duy vật biện chứng, vật chất được hiểu là gì?', '["Mọi cái nhìn thấy bằng mắt","Thực tại khách quan tồn tại độc lập với ý thức","Các nguyên tử nhỏ nhất","Tổng hợp cảm giác của con người"]',1,'Vật chất là thực tại khách quan, tồn tại không lệ thuộc vào cảm giác hay ý thức của con người.'),
('TRIET','Ý thức có nguồn gốc tự nhiên và xã hội như thế nào?', '["Chỉ có nguồn gốc tự nhiên","Chỉ có nguồn gốc xã hội","Có nguồn gốc tự nhiên và nguồn gốc xã hội","Do lực lượng siêu nhiên tạo ra"]',2,'Ý thức nảy sinh trên cơ sở bộ não người và đời sống xã hội, đặc biệt là lao động và ngôn ngữ.'),
('TRIET','Mối quan hệ đúng giữa vật chất và ý thức là gì?', '["Ý thức quyết định tuyệt đối vật chất","Vật chất quyết định ý thức, ý thức tác động trở lại vật chất","Hai bên không liên quan","Vật chất chỉ là sản phẩm của ý thức"]',1,'Vật chất có trước và quyết định ý thức; ý thức có tính độc lập tương đối và tác động trở lại thông qua hoạt động thực tiễn.'),
('TRIET','Phép biện chứng duy vật nghiên cứu điều gì?', '["Các quy luật phổ biến của sự vận động và phát triển","Chỉ các hiện tượng tâm lý","Các quy tắc suy luận hình thức","Lịch sử của một dân tộc"]',0,'Phép biện chứng duy vật nghiên cứu những mối liên hệ và quy luật vận động, phát triển phổ biến nhất.'),
('TRIET','Nguyên lý về mối liên hệ phổ biến khẳng định điều gì?', '["Mọi sự vật đều cô lập","Các sự vật tồn tại trong sự liên hệ, tác động qua lại","Chỉ có liên hệ bên ngoài","Liên hệ không có tính khách quan"]',1,'Mối liên hệ tồn tại khách quan, phổ biến và đa dạng giữa các sự vật, hiện tượng.'),
('TRIET','Phát triển theo quan điểm biện chứng là quá trình nào?', '["Tăng giảm cơ học đơn thuần","Vận động theo chiều hướng tiến lên từ thấp đến cao","Lặp lại y nguyên cái cũ","Thay đổi không có nguyên nhân"]',1,'Phát triển là vận động theo khuynh hướng đi lên, từ thấp đến cao, từ đơn giản đến phức tạp.'),
('TRIET','Quy luật lượng - chất chỉ ra điều gì?', '["Lượng và chất không liên hệ","Thay đổi lượng đến điểm nút sẽ dẫn đến bước nhảy về chất","Mọi thay đổi đều là bước nhảy","Chất không thể thay đổi"]',1,'Sự thay đổi về lượng tích lũy đến điểm nút sẽ tạo ra bước nhảy làm thay đổi chất.'),
('TRIET','Quy luật thống nhất và đấu tranh của các mặt đối lập là nguồn gốc của?', '["Sự đứng im tuyệt đối","Sự vận động và phát triển","Mọi sai lầm nhận thức","Sự ngẫu nhiên thuần túy"]',1,'Mâu thuẫn và sự giải quyết mâu thuẫn là nguồn gốc, động lực của vận động và phát triển.'),
('TRIET','Phủ định biện chứng có đặc điểm nào?', '["Sạch trơn, xóa bỏ hoàn toàn","Kế thừa và phát triển cái hợp lý của cái cũ","Do ý muốn chủ quan","Không tạo ra cái mới"]',1,'Phủ định biện chứng loại bỏ mặt lỗi thời nhưng kế thừa và cải biến những yếu tố tích cực.'),
('TRIET','Thực tiễn là cơ sở của nhận thức vì sao?', '["Nhận thức không cần hoạt động","Thực tiễn cung cấp đối tượng, nhu cầu và phương tiện cho nhận thức","Thực tiễn chỉ là suy nghĩ","Thực tiễn không kiểm tra được chân lý"]',1,'Hoạt động thực tiễn đặt ra vấn đề, cung cấp dữ liệu và phương tiện để con người nhận thức thế giới.'),
('TRIET','Tiêu chuẩn khách quan của chân lý là gì?', '["Số đông đồng ý","Thực tiễn","Cảm xúc cá nhân","Thói quen"]',1,'Thực tiễn là tiêu chuẩn khách quan để kiểm nghiệm tính đúng đắn của tri thức.'),
('TRIET','Nhận thức cảm tính gồm những hình thức nào?', '["Khái niệm, phán đoán, suy luận","Cảm giác, tri giác, biểu tượng","Giả thuyết, lý thuyết, tiên đề","Bản năng, trực giác, niềm tin"]',1,'Cảm giác, tri giác và biểu tượng là các hình thức cơ bản của nhận thức cảm tính.'),
('TRIET','Nhận thức lý tính gồm những hình thức nào?', '["Cảm giác và tri giác","Khái niệm, phán đoán và suy luận","Bản năng và cảm xúc","Quan sát và thí nghiệm בלבד"]',1,'Nhận thức lý tính khái quát bản chất sự vật bằng khái niệm, phán đoán và suy luận.'),
('TRIET','Chân lý có những tính chất cơ bản nào?', '["Tuyệt đối, tương đối, khách quan và cụ thể","Chỉ tuyệt đối","Chỉ tương đối","Chủ quan và bất biến"]',0,'Chân lý có tính khách quan, tính cụ thể, đồng thời bao gồm mặt tuyệt đối và tương đối.'),
('TRIET','Lực lượng sản xuất bao gồm những yếu tố chủ yếu nào?', '["Người lao động và tư liệu sản xuất","Nhà nước và pháp luật","Tôn giáo và đạo đức","Thị trường và tiền tệ בלבד"]',0,'Lực lượng sản xuất gồm người lao động và tư liệu sản xuất, trong đó người lao động giữ vai trò quyết định.'),
('TRIET','Quan hệ sản xuất là quan hệ của con người trong quá trình nào?', '["Tiêu dùng cá nhân","Sản xuất vật chất","Giải trí","Học tập בלבד"]',1,'Quan hệ sản xuất là các quan hệ kinh tế giữa người với người trong quá trình sản xuất và tái sản xuất xã hội.'),
('TRIET','Cơ sở hạ tầng của xã hội là gì?', '["Toàn bộ quan hệ sản xuất hợp thành cơ cấu kinh tế","Hệ thống đường sá","Toàn bộ thiết bị kỹ thuật","Các công trình công cộng"]',0,'Cơ sở hạ tầng là toàn bộ những quan hệ sản xuất hợp thành cơ cấu kinh tế của xã hội.'),
('TRIET','Kiến trúc thượng tầng bao gồm những gì?', '["Chỉ nền kinh tế","Các quan điểm, thiết chế và tổ chức chính trị - xã hội tương ứng","Chỉ máy móc sản xuất","Chỉ dân số"]',1,'Kiến trúc thượng tầng gồm hệ tư tưởng và các thiết chế, tổ chức được xây dựng trên cơ sở hạ tầng.'),
('TRIET','Hình thái kinh tế - xã hội là phạm trù dùng để chỉ?', '["Một kiểu tổ chức xã hội trong một giai đoạn lịch sử nhất định","Một cá nhân","Một loại hàng hóa","Một quy tắc logic"]',0,'Hình thái kinh tế - xã hội là xã hội ở một giai đoạn lịch sử với quan hệ sản xuất và kiến trúc thượng tầng tương ứng.'),
('TRIET','Tồn tại xã hội quyết định yếu tố nào?', '["Ý thức xã hội","Mọi cảm xúc cá nhân trực tiếp","Quy luật tự nhiên","Toán học"]',0,'Tồn tại xã hội quyết định ý thức xã hội, nhưng ý thức xã hội có thể tác động trở lại tồn tại xã hội.'),
('TRIET','Giai cấp xuất hiện do nguyên nhân chủ yếu nào?', '["Sự khác nhau về sở thích","Sự phát triển của lực lượng sản xuất và chế độ tư hữu","Sự khác nhau về tuổi","Sự thay đổi thời tiết"]',1,'Giai cấp xuất hiện gắn với sự phát triển của sản xuất, chế độ tư hữu và sự phân hóa xã hội.'),
('TRIET','Con người trong triết học Mác được xem là?', '["Thực thể sinh học thuần túy","Thực thể sinh học - xã hội và là tổng hòa các quan hệ xã hội","Sản phẩm của tự nhiên không biến đổi","Cá nhân tách khỏi cộng đồng"]',1,'Con người vừa có mặt tự nhiên vừa có mặt xã hội; bản chất người được hình thành trong các quan hệ xã hội.'),
('TRIET','Vai trò của lao động đối với sự hình thành con người là gì?', '["Không đáng kể","Lao động góp phần hình thành bàn tay, ngôn ngữ và đời sống xã hội","Chỉ tạo ra của cải","Chỉ tạo ra bản năng"]',1,'Lao động là hoạt động xã hội - lịch sử góp phần biến đổi cơ thể, ngôn ngữ và năng lực ý thức của con người.'),
('TRIET','Quan điểm toàn diện yêu cầu khi xem xét sự vật phải?', '["Chỉ nhìn một mặt","Đặt sự vật trong các mối liên hệ và điều kiện cụ thể","Bỏ qua hoàn cảnh","Chỉ dựa vào kinh nghiệm cũ"]',1,'Quan điểm toàn diện yêu cầu xem xét nhiều mặt, nhiều mối liên hệ và xác định mối liên hệ chủ yếu.'),
('TRIET','Quan điểm lịch sử - cụ thể yêu cầu?', '["Áp dụng một công thức cho mọi nơi","Xem xét sự vật trong hoàn cảnh lịch sử cụ thể","Không cần dữ liệu","Chỉ xem hiện tại"]',1,'Mỗi sự vật cần được phân tích trong điều kiện, thời gian, không gian và quan hệ cụ thể của nó.'),
('TRIET','Nguyên tắc thống nhất giữa lý luận và thực tiễn có nghĩa là?', '["Lý luận tách khỏi đời sống","Lý luận phải xuất phát từ thực tiễn và được thực tiễn kiểm nghiệm","Chỉ cần kinh nghiệm","Thực tiễn không cần lý luận"]',1,'Lý luận hình thành từ thực tiễn, hướng dẫn thực tiễn và phải được thực tiễn kiểm nghiệm.'),
('TRIET','Sản xuất vật chất giữ vai trò nào trong đời sống xã hội?', '["Không có vai trò","Là cơ sở của sự tồn tại và phát triển xã hội","Chỉ phục vụ cá nhân","Chỉ tạo ra văn hóa"]',1,'Sản xuất vật chất tạo ra tư liệu sinh hoạt và là cơ sở của các quan hệ, hoạt động xã hội khác.'),
('TRIET','Tự do theo quan điểm duy vật biện chứng là gì?', '["Muốn làm gì cũng được","Nhận thức và vận dụng quy luật khách quan","Không bị ràng buộc bởi thực tế","Phủ nhận tất yếu"]',1,'Tự do là khả năng nhận thức và hành động phù hợp với các quy luật khách quan.'),
('TRIET','Vai trò của quần chúng nhân dân trong lịch sử là?', '["Không đáng kể","Là lực lượng sáng tạo chân chính ra lịch sử","Chỉ tiếp nhận lịch sử","Chỉ làm theo lãnh tụ"]',1,'Quần chúng nhân dân là chủ thể sáng tạo ra các giá trị vật chất, tinh thần và những biến đổi lịch sử.'),
('TRIET','Ý nghĩa phương pháp luận của quy luật lượng - chất là?', '["Chỉ cần thay đổi chất","Phải kiên trì tích lũy lượng và biết thực hiện bước nhảy đúng lúc","Không cần chuẩn bị","Phủ nhận thay đổi từng bước"]',1,'Cần tích lũy đủ về lượng, đồng thời chủ động nắm thời cơ để thực hiện bước nhảy về chất.'),
('PLDC','Pháp luật là hệ thống quy tắc xử sự do chủ thể nào ban hành hoặc thừa nhận?', '["Mỗi cá nhân","Nhà nước","Gia đình","Một nhóm bạn"]',1,'Pháp luật là hệ thống quy tắc xử sự chung do Nhà nước ban hành hoặc thừa nhận và bảo đảm thực hiện.'),
('PLDC','Đặc điểm nào phân biệt pháp luật với đạo đức?', '["Đều có tính tự nguyện","Pháp luật có tính bắt buộc chung và được Nhà nước bảo đảm thực hiện","Đạo đức luôn có văn bản","Pháp luật chỉ áp dụng cho cán bộ"]',1,'Pháp luật có tính bắt buộc chung, hình thức xác định và được Nhà nước bảo đảm thực hiện.'),
('PLDC','Nguồn của pháp luật Việt Nam có thể bao gồm?', '["Văn bản quy phạm pháp luật và tập quán được thừa nhận","Tin đồn","Sở thích cá nhân","Nội quy gia đình בלבד"]',0,'Nguồn pháp luật có thể là văn bản quy phạm pháp luật và các nguồn được pháp luật thừa nhận trong từng trường hợp.'),
('PLDC','Quy phạm pháp luật thường gồm các bộ phận nào?', '["Giả định, quy định, chế tài","Mở bài, thân bài, kết luận","Chủ thể, khách thể בלבד","Nguyên nhân, kết quả"]',0,'Cấu trúc logic phổ biến của quy phạm pháp luật gồm giả định, quy định và chế tài.'),
('PLDC','Hiến pháp có vị trí như thế nào trong hệ thống pháp luật?', '["Là văn bản có hiệu lực pháp lý cao nhất","Thấp hơn mọi nghị định","Chỉ là văn bản tham khảo","Chỉ áp dụng cho doanh nghiệp"]',0,'Hiến pháp là luật cơ bản của Nhà nước, có hiệu lực pháp lý cao nhất.'),
('PLDC','Nhà nước pháp quyền xã hội chủ nghĩa Việt Nam được tổ chức và hoạt động theo?', '["Ý chí của một cá nhân","Hiến pháp và pháp luật","Phong tục riêng của từng nơi","Mệnh lệnh không thành văn"]',1,'Nhà nước pháp quyền yêu cầu Nhà nước được tổ chức, hoạt động trong khuôn khổ Hiến pháp và pháp luật.'),
('PLDC','Quyền lực nhà nước ở Việt Nam thuộc về?', '["Nhân dân","Một doanh nghiệp","Một gia đình","Một địa phương"]',0,'Hiến pháp xác định tất cả quyền lực nhà nước thuộc về Nhân dân.'),
('PLDC','Cơ quan thực hiện quyền lập hiến và lập pháp ở Việt Nam là?', '["Quốc hội","Tòa án nhân dân tối cao","Ủy ban nhân dân cấp xã","Doanh nghiệp"]',0,'Quốc hội là cơ quan đại biểu cao nhất của Nhân dân và là cơ quan quyền lực nhà nước cao nhất.'),
('PLDC','Chủ thể của quan hệ pháp luật có thể là?', '["Cá nhân, tổ chức đáp ứng điều kiện pháp luật","Chỉ người trên 60 tuổi","Chỉ cơ quan nhà nước","Chỉ người có tài sản"]',0,'Chủ thể quan hệ pháp luật là cá nhân, tổ chức có năng lực pháp luật và năng lực hành vi phù hợp.'),
('PLDC','Năng lực pháp luật của cá nhân là khả năng?', '["Có quyền và nghĩa vụ pháp lý","Luôn thắng kiện","Được miễn mọi trách nhiệm","Tự ban hành luật"]',0,'Năng lực pháp luật là khả năng có quyền và nghĩa vụ pháp lý do pháp luật quy định.'),
('PLDC','Vi phạm pháp luật phải có dấu hiệu nào?', '["Hành vi trái pháp luật, có lỗi, do chủ thể có năng lực trách nhiệm thực hiện","Chỉ cần gây khó chịu","Mọi suy nghĩ cá nhân","Hành vi luôn vô ý בלבד"]',0,'Vi phạm pháp luật là hành vi trái pháp luật, có lỗi, do chủ thể có năng lực trách nhiệm pháp lý thực hiện.'),
('PLDC','Trách nhiệm pháp lý là?', '["Hậu quả bất lợi mà chủ thể vi phạm phải gánh chịu","Một lời khuyên","Phần thưởng","Quyền tự do tuyệt đối"]',0,'Trách nhiệm pháp lý là nghĩa vụ chịu các biện pháp cưỡng chế hoặc hậu quả bất lợi do vi phạm pháp luật.'),
('PLDC','Trách nhiệm hình sự áp dụng đối với hành vi nào?', '["Tội phạm theo quy định của Bộ luật Hình sự","Mọi lỗi giao tiếp","Mọi vi phạm nội quy lớp","Mọi tranh chấp dân sự"]',0,'Trách nhiệm hình sự áp dụng với người thực hiện hành vi bị Bộ luật Hình sự quy định là tội phạm.'),
('PLDC','Trách nhiệm dân sự thường nhằm mục đích nào?', '["Bồi thường thiệt hại hoặc thực hiện nghĩa vụ dân sự","Tước quyền bầu cử mọi trường hợp","Cách ly mọi người","Thay thế giáo dục"]',0,'Trách nhiệm dân sự chủ yếu khôi phục quyền, lợi ích bị xâm phạm bằng bồi thường hoặc thực hiện nghĩa vụ.'),
('PLDC','Hợp đồng dân sự là sự thỏa thuận nhằm?', '["Xác lập, thay đổi hoặc chấm dứt quyền và nghĩa vụ dân sự","Tạo ra tội phạm","Ban hành hiến pháp","Thay thế mọi quy định pháp luật"]',0,'Hợp đồng là sự thỏa thuận giữa các bên về việc xác lập, thay đổi hoặc chấm dứt quyền và nghĩa vụ dân sự.'),
('PLDC','Điều kiện cơ bản để giao dịch dân sự có hiệu lực gồm?', '["Chủ thể có năng lực, tự nguyện, mục đích hợp pháp và đúng hình thức khi luật yêu cầu","Chỉ cần nói miệng trong mọi trường hợp","Chỉ cần có người chứng kiến","Chỉ cần có tài sản"]',0,'Giao dịch cần chủ thể phù hợp, tự nguyện, mục đích nội dung hợp pháp và hình thức đúng khi pháp luật yêu cầu.'),
('PLDC','Luật lao động điều chỉnh quan hệ chủ yếu nào?', '["Quan hệ lao động giữa người lao động và người sử dụng lao động","Quan hệ huyết thống","Quan hệ quốc tế בלבד","Quan hệ tôn giáo"]',0,'Luật lao động điều chỉnh quan hệ lao động và các quan hệ liên quan giữa người lao động, người sử dụng lao động.'),
('PLDC','Nguyên tắc bình đẳng trong quan hệ lao động có nghĩa là?', '["Các bên có quyền, nghĩa vụ theo thỏa thuận và pháp luật, không phân biệt trái luật","Người sử dụng lao động luôn đúng","Người lao động không có quyền","Mọi hợp đồng đều vô hiệu"]',0,'Các bên tham gia quan hệ lao động phải được đối xử bình đẳng trong khuôn khổ pháp luật.'),
('PLDC','Luật hành chính điều chỉnh chủ yếu các quan hệ?', '["Quản lý hành chính nhà nước","Mua bán tài sản cá nhân","Hôn nhân בלבד","Sở hữu trí tuệ בלבד"]',0,'Luật hành chính điều chỉnh quan hệ phát sinh trong hoạt động quản lý hành chính nhà nước.'),
('PLDC','Khiếu nại là việc công dân đề nghị?', '["Cơ quan, tổ chức hoặc cá nhân có thẩm quyền xem xét lại quyết định, hành vi khi có căn cứ cho rằng quyền lợi bị xâm phạm","Tòa án ban hành luật","Hủy mọi bản án","Miễn nghĩa vụ thuế"]',0,'Khiếu nại là yêu cầu xem xét lại quyết định hoặc hành vi hành chính ảnh hưởng đến quyền, lợi ích hợp pháp.'),
('PLDC','Tòa án nhân dân thực hiện quyền nào?', '["Quyền tư pháp","Quyền lập pháp בלבד","Quyền kinh doanh","Quyền quản lý doanh nghiệp"]',0,'Tòa án nhân dân là cơ quan xét xử, thực hiện quyền tư pháp.'),
('PLDC','Nguyên tắc suy đoán vô tội có nghĩa là?', '["Người bị buộc tội được coi là không có tội cho đến khi được chứng minh theo trình tự luật định","Ai bị tố cáo cũng có tội","Chỉ người già được bảo vệ","Không cần chứng cứ"]',0,'Một người chỉ bị coi là có tội khi được chứng minh theo trình tự luật định và có bản án kết tội có hiệu lực.'),
('PLDC','Quyền sở hữu gồm những quyền nào?', '["Chiếm hữu, sử dụng và định đoạt","Chỉ sử dụng","Chỉ mua bán","Chỉ thừa kế"]',0,'Quyền sở hữu bao gồm quyền chiếm hữu, quyền sử dụng và quyền định đoạt tài sản.'),
('PLDC','Thừa kế theo pháp luật được áp dụng khi?', '["Không có di chúc hợp pháp hoặc thuộc trường hợp pháp luật quy định","Mọi người còn sống","Không có tài sản","Chỉ khi hàng xóm đồng ý"]',0,'Thừa kế theo pháp luật áp dụng khi không có di chúc hợp pháp hoặc di chúc không bao quát trường hợp luật định.'),
('PLDC','Mục đích của pháp luật bảo vệ quyền con người là?', '["Ghi nhận, tôn trọng, bảo vệ và bảo đảm các quyền hợp pháp","Hạn chế mọi quyền","Chỉ bảo vệ cơ quan nhà nước","Xóa bỏ nghĩa vụ"]',0,'Pháp luật ghi nhận và thiết lập cơ chế bảo vệ, bảo đảm quyền con người, quyền công dân.'),
('PLDC','Nguyên tắc mọi người bình đẳng trước pháp luật yêu cầu?', '["Không phân biệt đối xử trái pháp luật trong hưởng quyền và thực hiện nghĩa vụ","Người có chức vụ được miễn luật","Chỉ công dân thành phố được bảo vệ","Mọi người có kết quả giống nhau"]',0,'Mọi người phải được đối xử bình đẳng trước pháp luật, không bị phân biệt đối xử trái quy định.'),
('PLDC','Phòng, chống tham nhũng hướng đến mục tiêu nào?', '["Ngăn chặn, phát hiện và xử lý hành vi tham nhũng, xây dựng bộ máy liêm chính","Hợp thức hóa hối lộ","Giảm minh bạch","Miễn trách nhiệm cho người có chức vụ"]',0,'Phòng, chống tham nhũng nhằm ngăn ngừa, phát hiện, xử lý tham nhũng và xây dựng nền quản trị liêm chính.'),
('PLDC','Văn bản quy phạm pháp luật có đặc điểm nào?', '["Chứa quy tắc xử sự chung, được ban hành đúng thẩm quyền và hình thức","Chỉ áp dụng cho một người","Không cần thẩm quyền","Chỉ là thư cá nhân"]',0,'Văn bản quy phạm pháp luật chứa quy tắc xử sự chung và phải được ban hành đúng thẩm quyền, trình tự, hình thức.'),
('PLDC','Một công dân có nghĩa vụ cơ bản nào?', '["Tuân theo Hiến pháp và pháp luật","Chỉ tuân theo ý kiến cá nhân","Không cần nộp thuế","Không cần bảo vệ Tổ quốc"]',0,'Tuân thủ Hiến pháp và pháp luật là nghĩa vụ cơ bản của công dân.'),
('PLDC','Pháp chế xã hội chủ nghĩa yêu cầu?', '["Tôn trọng, chấp hành và bảo vệ pháp luật trong tổ chức và đời sống xã hội","Chỉ áp dụng luật cho người dân","Đặt lợi ích cá nhân cao hơn luật","Không cần kiểm tra pháp luật"]',0,'Pháp chế yêu cầu mọi tổ chức, cá nhân tôn trọng, chấp hành và bảo vệ pháp luật một cách nghiêm minh.'),
('PLDC','Mục đích của hình phạt trong pháp luật hình sự không bao gồm?', '["Giáo dục, phòng ngừa và trừng trị người phạm tội","Khuyến khích tái phạm","Bảo vệ công lý","Phòng ngừa tội phạm"]',1,'Hình phạt không nhằm khuyến khích tái phạm; nó có mục đích trừng trị, giáo dục và phòng ngừa.'),
('PLDC','Bảo vệ môi trường là trách nhiệm của?', '["Nhà nước, tổ chức, cộng đồng và mỗi cá nhân","Chỉ doanh nghiệp","Chỉ cơ quan môi trường","Chỉ người vi phạm"]',0,'Bảo vệ môi trường là trách nhiệm chung của Nhà nước, tổ chức, cộng đồng và từng cá nhân.'),
('PLDC','Một trong các nguyên tắc tổ chức bộ máy nhà nước là?', '["Quyền lực nhà nước được phân công, phối hợp và kiểm soát","Không có kiểm soát quyền lực","Mỗi cơ quan tự đặt luật","Cá nhân đứng trên pháp luật"]',0,'Quyền lực nhà nước được phân công, phối hợp và kiểm soát giữa các cơ quan trong thực hiện quyền lực.'),
('PLDC','Tôn trọng quyền riêng tư trong môi trường số yêu cầu?', '["Thu thập và sử dụng dữ liệu cá nhân theo căn cứ, mục đích và quy định pháp luật","Công khai mọi dữ liệu","Chia sẻ mật khẩu tùy ý","Bỏ qua sự đồng ý trong mọi trường hợp"]',0,'Dữ liệu cá nhân phải được xử lý có căn cứ, đúng mục đích và tuân thủ các yêu cầu bảo vệ dữ liệu.'),
('PLDC','Biện pháp pháp lý phù hợp khi phát hiện hành vi lừa đảo là?', '["Lưu chứng cứ và báo cơ quan có thẩm quyền","Đăng thông tin cá nhân của nghi phạm tùy ý","Đe dọa trả thù","Xóa mọi chứng cứ"]',0,'Cần bảo toàn chứng cứ và thông báo cơ quan có thẩm quyền để xử lý theo pháp luật.'),
('PLDC','Ý thức pháp luật là?', '["Tổng thể tri thức, tình cảm và thái độ của con người đối với pháp luật","Chỉ là văn bản luật","Chỉ là hình phạt","Một loại tài sản"]',0,'Ý thức pháp luật bao gồm tri thức, tình cảm, niềm tin và thái độ của con người đối với pháp luật.');

do $$
declare
  row record;
  quiz_id uuid;
  question_id uuid;
  option_text text;
  option_number integer;
begin
  for row in select * from _question_seed loop
    select q.id into quiz_id
    from public.quizzes q
    join public.subjects s on s.id = q.subject_id
    where s.code = row.code;

    if not exists (
      select 1 from public.quiz_questions existing_question
      where existing_question.quiz_id = quiz_id
        and existing_question.question_text = row.question_text
    ) then
      insert into public.quiz_questions (quiz_id, question_text, explanation, sort_order)
      values (quiz_id, row.question_text, row.explanation,
              (select coalesce(max(existing_question.sort_order), -1) + 1
               from public.quiz_questions existing_question
               where existing_question.quiz_id = quiz_id))
      returning id into question_id;

      for option_number in 0..3 loop
        option_text := row.options ->> option_number;
        insert into public.quiz_options (question_id, option_text, option_index, is_correct)
        values (question_id, option_text, option_number, option_number = row.correct_index);
      end loop;
    end if;
  end loop;
end $$;

notify pgrst, 'reload schema';
