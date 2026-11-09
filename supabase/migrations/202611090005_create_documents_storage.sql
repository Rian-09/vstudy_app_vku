-- Private Storage bucket for document files. Metadata lives in public.documents.
insert into storage.buckets (id, name, public)
values ('documents', 'documents', false)
on conflict (id) do update set public = false;

drop policy if exists documents_storage_read on storage.objects;
create policy documents_storage_read
on storage.objects for select
to authenticated
using (
  bucket_id = 'documents'
  and (
    public.is_admin_user()
    or exists (
      select 1
      from public.documents d
      where d.file_path = name
        and d.is_published
    )
  )
);

drop policy if exists documents_storage_admin_insert on storage.objects;
create policy documents_storage_admin_insert
on storage.objects for insert
to authenticated
with check (bucket_id = 'documents' and public.is_admin_user());

drop policy if exists documents_storage_admin_update on storage.objects;
create policy documents_storage_admin_update
on storage.objects for update
to authenticated
using (bucket_id = 'documents' and public.is_admin_user())
with check (bucket_id = 'documents' and public.is_admin_user());

drop policy if exists documents_storage_admin_delete on storage.objects;
create policy documents_storage_admin_delete
on storage.objects for delete
to authenticated
using (bucket_id = 'documents' and public.is_admin_user());

notify pgrst, 'reload schema';
