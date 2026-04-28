-- ReviewHub: tabla principal de reseñas
-- Ejecutar en Supabase SQL Editor

create table if not exists reviews (
  id            uuid primary key default gen_random_uuid(),
  camping_name  text not null,
  author_name   text not null,
  rating        int  not null check (rating between 1 and 5),
  review_text   text,
  ai_response   text,
  custom_response text,
  status        text not null default 'pending'
                check (status in ('pending','auto','approved','responded','ignored')),
  google_review_id text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- Índices útiles para filtros frecuentes
create index if not exists reviews_camping_name_idx on reviews (camping_name);
create index if not exists reviews_rating_idx       on reviews (rating);
create index if not exists reviews_status_idx       on reviews (status);

-- Trigger para actualizar updated_at automáticamente
create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists reviews_set_updated_at on reviews;
create trigger reviews_set_updated_at
  before update on reviews
  for each row execute function set_updated_at();

-- RLS: acceso público de lectura/escritura (ajustar en producción)
alter table reviews enable row level security;

drop policy if exists "allow_all" on reviews;
create policy "allow_all" on reviews
  for all using (true) with check (true);
