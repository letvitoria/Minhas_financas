-- Grana Jovem: schema inicial. Execute no SQL Editor do Supabase.
-- Todas as tabelas expostas usam RLS e ownership por auth.uid().

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 120),
  type text not null check (type in ('income', 'expense', 'investment')),
  category text not null default 'Geral',
  amount numeric(12,2) not null check (amount > 0),
  occurred_on date not null default current_date,
  created_at timestamptz not null default now()
);

create table if not exists public.bills (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 120),
  amount numeric(12,2) not null check (amount > 0),
  due_date date not null,
  recurrence text not null default 'monthly' check (recurrence in ('none', 'monthly', 'yearly')),
  is_paid boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.income_sources (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 120),
  amount numeric(12,2) not null check (amount > 0),
  frequency text not null default 'monthly' check (frequency in ('monthly', 'extra')),
  received_on date not null default current_date,
  created_at timestamptz not null default now()
);

create table if not exists public.investments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 120),
  category text not null check (category in ('Renda Fixa', 'Global', 'Fundos', 'Ações', 'Cripto', 'Outros')),
  amount numeric(12,2) not null check (amount > 0),
  created_at timestamptz not null default now()
);

create table if not exists public.wishlist_goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 120),
  target_amount numeric(12,2) not null check (target_amount > 0),
  saved_amount numeric(12,2) not null default 0 check (saved_amount >= 0),
  target_date date,
  created_at timestamptz not null default now(),
  constraint saved_not_over_target check (saved_amount <= target_amount)
);

-- Privileges: autenticação é necessária para acessar dados financeiros.
grant select, insert, update, delete on public.transactions to authenticated;
grant select, insert, update, delete on public.bills to authenticated;
grant select, insert, update, delete on public.income_sources to authenticated;
grant select, insert, update, delete on public.investments to authenticated;
grant select, insert, update, delete on public.wishlist_goals to authenticated;

alter table public.transactions enable row level security;
alter table public.bills enable row level security;
alter table public.income_sources enable row level security;
alter table public.investments enable row level security;
alter table public.wishlist_goals enable row level security;

drop policy if exists "Users manage own transactions" on public.transactions;
create policy "Users manage own transactions" on public.transactions
for all to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "Users manage own bills" on public.bills;
create policy "Users manage own bills" on public.bills
for all to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "Users manage own income sources" on public.income_sources;
create policy "Users manage own income sources" on public.income_sources
for all to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "Users manage own investments" on public.investments;
create policy "Users manage own investments" on public.investments
for all to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "Users manage own wishlist goals" on public.wishlist_goals;
create policy "Users manage own wishlist goals" on public.wishlist_goals
for all to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create index if not exists transactions_user_date_idx on public.transactions(user_id, occurred_on desc);
create index if not exists bills_user_due_idx on public.bills(user_id, due_date);
create index if not exists income_user_date_idx on public.income_sources(user_id, received_on desc);
create index if not exists investments_user_category_idx on public.investments(user_id, category);
create index if not exists wishlist_user_idx on public.wishlist_goals(user_id);
