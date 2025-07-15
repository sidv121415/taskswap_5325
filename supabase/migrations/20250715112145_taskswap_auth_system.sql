-- TaskSwap Authentication & Task Management System
-- Migration: 20250715112145_taskswap_auth_system.sql

-- 1. Create custom types
CREATE TYPE public.user_role AS ENUM ('admin', 'user');
CREATE TYPE public.task_priority AS ENUM ('low', 'medium', 'high');
CREATE TYPE public.task_status AS ENUM ('pending', 'completed');
CREATE TYPE public.connection_status AS ENUM ('pending', 'accepted', 'declined');

-- 2. Create user_profiles table (PostgREST compatibility)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    photo TEXT,
    bio TEXT,
    role public.user_role DEFAULT 'user'::public.user_role,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Create connection_requests table
CREATE TABLE public.connection_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    to_user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    status public.connection_status DEFAULT 'pending'::public.connection_status,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(from_user_id, to_user_id)
);

-- 4. Create tasks table
CREATE TABLE public.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    priority public.task_priority DEFAULT 'medium'::public.task_priority,
    due_date TIMESTAMPTZ,
    status public.task_status DEFAULT 'pending'::public.task_status,
    assigned_by UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    assigned_to UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Create notifications table
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    message TEXT NOT NULL,
    read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 6. Create indexes
CREATE INDEX idx_user_profiles_username ON public.user_profiles(username);
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_connection_requests_from_user ON public.connection_requests(from_user_id);
CREATE INDEX idx_connection_requests_to_user ON public.connection_requests(to_user_id);
CREATE INDEX idx_connection_requests_status ON public.connection_requests(status);
CREATE INDEX idx_tasks_assigned_by ON public.tasks(assigned_by);
CREATE INDEX idx_tasks_assigned_to ON public.tasks(assigned_to);
CREATE INDEX idx_tasks_status ON public.tasks(status);
CREATE INDEX idx_tasks_priority ON public.tasks(priority);
CREATE INDEX idx_tasks_due_date ON public.tasks(due_date);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_read ON public.notifications(read);

-- 7. Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.connection_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 8. Helper Functions
CREATE OR REPLACE FUNCTION public.is_connected(user1_id UUID, user2_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.connection_requests cr
    WHERE (cr.from_user_id = user1_id AND cr.to_user_id = user2_id)
    OR (cr.from_user_id = user2_id AND cr.to_user_id = user1_id)
    AND cr.status = 'accepted'::public.connection_status
)
$$;

CREATE OR REPLACE FUNCTION public.owns_task(task_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.tasks t
    WHERE t.id = task_uuid 
    AND (t.assigned_by = auth.uid() OR t.assigned_to = auth.uid())
)
$$;

CREATE OR REPLACE FUNCTION public.can_assign_task(target_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT public.is_connected(auth.uid(), target_user_id) OR auth.uid() = target_user_id
$$;

CREATE OR REPLACE FUNCTION public.owns_connection_request(request_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.connection_requests cr
    WHERE cr.id = request_uuid
    AND (cr.from_user_id = auth.uid() OR cr.to_user_id = auth.uid())
)
$$;

-- 9. Profile creation trigger
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, username, name, email, phone, photo, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
        NEW.email,
        NEW.raw_user_meta_data->>'phone',
        NEW.raw_user_meta_data->>'photo',
        COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'user'::public.user_role)
    );
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 10. RLS Policies
CREATE POLICY "users_view_own_profile" ON public.user_profiles
FOR SELECT TO authenticated
USING (auth.uid() = id);

CREATE POLICY "users_update_own_profile" ON public.user_profiles
FOR UPDATE TO authenticated
USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

CREATE POLICY "public_can_search_users" ON public.user_profiles
FOR SELECT TO authenticated
USING (true);

CREATE POLICY "users_manage_own_connection_requests" ON public.connection_requests
FOR ALL TO authenticated
USING (public.owns_connection_request(id)) 
WITH CHECK (public.owns_connection_request(id));

CREATE POLICY "users_view_connected_requests" ON public.connection_requests
FOR SELECT TO authenticated
USING (from_user_id = auth.uid() OR to_user_id = auth.uid());

CREATE POLICY "users_manage_own_tasks" ON public.tasks
FOR ALL TO authenticated
USING (public.owns_task(id))
WITH CHECK (public.owns_task(id));

CREATE POLICY "users_view_own_notifications" ON public.notifications
FOR SELECT TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "users_update_own_notifications" ON public.notifications
FOR UPDATE TO authenticated
USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- 11. Mock Data
DO $$
DECLARE
    user1_id UUID := gen_random_uuid();
    user2_id UUID := gen_random_uuid();
    user3_id UUID := gen_random_uuid();
    request1_id UUID := gen_random_uuid();
    request2_id UUID := gen_random_uuid();
    task1_id UUID := gen_random_uuid();
    task2_id UUID := gen_random_uuid();
    task3_id UUID := gen_random_uuid();
BEGIN
    -- Create auth users
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (user1_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'sara@example.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"username": "sara_k", "name": "Sara Kumar", "phone": "+91 9876543210"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user2_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'john@example.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"username": "john_doe", "name": "John Doe", "phone": "+1 5551234567"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user3_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@example.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"username": "admin", "name": "Admin User", "role": "admin"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create connection requests
    INSERT INTO public.connection_requests (id, from_user_id, to_user_id, status) VALUES
        (request1_id, user1_id, user2_id, 'accepted'::public.connection_status),
        (request2_id, user1_id, user3_id, 'pending'::public.connection_status);

    -- Create tasks
    INSERT INTO public.tasks (id, title, description, priority, due_date, status, assigned_by, assigned_to) VALUES
        (task1_id, 'Clean kitchen', 'Deep clean before weekend', 'high'::public.task_priority, 
         '2025-07-20T18:00:00Z'::timestamptz, 'pending'::public.task_status, user1_id, user2_id),
        (task2_id, 'Review document', 'Please review the project proposal', 'medium'::public.task_priority, 
         '2025-07-18T12:00:00Z'::timestamptz, 'pending'::public.task_status, user2_id, user1_id),
        (task3_id, 'Backup files', 'Create backup of important files', 'low'::public.task_priority, 
         '2025-07-25T10:00:00Z'::timestamptz, 'completed'::public.task_status, user1_id, user1_id);

    -- Create notifications
    INSERT INTO public.notifications (user_id, type, message) VALUES
        (user2_id, 'task_assigned', 'Sara assigned you a task: Clean kitchen'),
        (user1_id, 'task_assigned', 'John assigned you a task: Review document'),
        (user3_id, 'connection_request', 'Sara sent you a connection request');

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Duplicate data detected, skipping mock data insertion';
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Error during mock data insertion: %', SQLERRM;
END $$;

-- 12. Cleanup function
CREATE OR REPLACE FUNCTION public.cleanup_test_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    test_user_ids UUID[];
BEGIN
    -- Get test user IDs
    SELECT ARRAY_AGG(id) INTO test_user_ids
    FROM auth.users
    WHERE email IN ('sara@example.com', 'john@example.com', 'admin@example.com');

    -- Delete in dependency order
    DELETE FROM public.notifications WHERE user_id = ANY(test_user_ids);
    DELETE FROM public.tasks WHERE assigned_by = ANY(test_user_ids) OR assigned_to = ANY(test_user_ids);
    DELETE FROM public.connection_requests WHERE from_user_id = ANY(test_user_ids) OR to_user_id = ANY(test_user_ids);
    DELETE FROM public.user_profiles WHERE id = ANY(test_user_ids);
    DELETE FROM auth.users WHERE id = ANY(test_user_ids);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents deletion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;