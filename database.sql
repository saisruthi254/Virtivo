--Table-1
--Row level security for user profiles and skills--
ALTER TABLE users_profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE users_skills ENABLE ROW LEVEL SECURITY;


CREATE POLICY "Allow users to insert their own profile" 
ON users_profile FOR INSERT 
TO authenticated 
WITH CHECK (true);


CREATE POLICY "Allow users to insert their own skills" 
ON users_skills FOR INSERT 
TO authenticated 
WITH CHECK (true);


CREATE POLICY "Allow everyone to read profiles" 
ON users_profile FOR SELECT 
TO authenticated 
USING (true);

CREATE POLICY "Allow everyone to read skills" 
ON users_skills FOR SELECT 
TO authenticated 
USING (true);

--Table-2
--User Skills UUID default & RLC Insert policy--

ALTER TABLE users_skills 
ALTER COLUMN id SET DEFAULT gen_random_uuid();


ALTER TABLE users_skills ENABLE ROW LEVEL SECURITY;


CREATE POLICY "Allow authenticated inserts" 
ON users_skills FOR INSERT 
TO authenticated 
WITH CHECK (true);

--Table 3
--Requests with RLC access control
create table requests (
  id uuid default uuid_generate_v4() primary key,
  sender_id uuid references users_profile(id) not null,
  receiver_id uuid references users_profile(id) not null,
  skill_name text not null,
  status text default 'pending', 
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);


alter table requests enable row level security;

create policy "Users can see their own requests" on requests
  for select using (auth.uid() = sender_id or auth.uid() = receiver_id);

create policy "Users can send requests" on requests
  for insert with check (auth.uid() = sender_id);

create policy "Receivers can update status" on requests
  for update using (auth.uid() = receiver_id);

--Table 4
--Messages Table
drop table if exists messages;

create table messages (
  id uuid default uuid_generate_v4() primary key,
  sender_id uuid,
  receiver_id uuid,
  content text,
  created_at timestamp default now()
);




