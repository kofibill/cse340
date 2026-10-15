CREATE TABLE organization (
    organization_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    contact_email VARCHAR(255) NOT NULL,
    logo_filename VARCHAR(255) NOT NULL
);

INSERT INTO organization (name, description, contact_email, logo_filename)
VALUES
('BrightFuture Builders', 'A nonprofit focused on improving community infrastructure through sustainable construction projects.', 'info@brightfuturebuilders.org', 'brightfuture-logo.png'),
('GreenHarvest Growers', 'An urban farming collective promoting food sustainability and education in local neighborhoods.', 'contact@greenharvest.org', 'greenharvest-logo.png'),
('UnityServe Volunteers', 'A volunteer coordination group supporting local charities and service initiatives.', 'hello@unityserve.org', 'unityserve-logo.png');

select organization_id, name, description, contact_email, logo_filename
from organization;

CREATE TABLE service_projects (
    project_id SERIAL PRIMARY KEY,
    organization_id INTEGER NOT NULL REFERENCES organization(organization_id),
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(100) NOT NULL,
    project_date DATE NOT NULL
);
-- BrightFuture Builders (organization_id = 1)
INSERT INTO service_projects (organization_id, title, description, location, project_date) VALUES
(1, 'Park Cleanup Day', 'Volunteers pick up litter and restore trails at the local park.', 'Riverside Park', '2026-10-04'),
(1, 'Playground Build', 'Assemble a new playground structure for a community elementary school.', 'Lincoln Elementary', '2026-10-18'),
(1, 'Home Repair Blitz', 'Small repair and paint jobs for elderly homeowners in the area.', 'Maple Street District', '2026-11-01'),
(1, 'Trail Restoration', 'Clear overgrowth and repair erosion damage on a hiking trail.', 'Cedar Ridge Trail', '2026-11-15'),
(1, 'Winter Shelter Setup', 'Set up cots and supplies ahead of the seasonal overnight shelter opening.', 'Downtown Community Center', '2026-12-02');

-- GreenHarvest Growers (organization_id = 2)
INSERT INTO service_projects (organization_id, title, description, location, project_date) VALUES
(2, 'Community Garden Planting', 'Plant a new season of vegetables in the shared community garden plots.', 'Elm Street Garden', '2026-10-10'),
(2, 'Compost Workshop', 'Teach households how to start and maintain a home compost bin.', 'Greenhouse Annex', '2026-10-24'),
(2, 'Farmers Market Support', 'Help set up and staff the weekly volunteer-run farmers market.', 'Town Square', '2026-11-07'),
(2, 'Seed Bank Sorting', 'Sort and label donated seeds for next season''s distribution.', 'GreenHarvest Warehouse', '2026-11-21'),
(2, 'Orchard Cleanup', 'Prune and clear debris from the community orchard before winter.', 'Orchard Lane', '2026-12-05');

-- UnityServe Volunteers (organization_id = 3)
INSERT INTO service_projects (organization_id, title, description, location, project_date) VALUES
(3, 'Reading Buddies Kickoff', 'Pair volunteers with elementary students for weekly reading sessions.', 'Jefferson Elementary', '2026-10-08'),
(3, 'Food Pantry Stocking', 'Sort and shelve donated food items at the community pantry.', 'Unity Food Pantry', '2026-10-22'),
(3, 'Senior Tech Help Day', 'Assist senior citizens with smartphones, email, and video calls.', 'Senior Center', '2026-11-05'),
(3, 'Coat Drive Collection', 'Collect and sort donated winter coats for distribution.', 'UnityServe Office', '2026-11-19'),
(3, 'Youth Mentoring Night', 'Facilitate a mentoring and homework help session for local teens.', 'Community Youth Hall', '2026-12-03');

SELECT
        sp.project_id,
        sp.title,
        sp.description,
        sp.location,
        sp.project_date,
        o.name AS organization_name
    FROM public.service_projects sp
    JOIN public.organization o ON sp.organization_id = o.organization_id
    ORDER BY sp.project_date;

CREATE TABLE category (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE project_category (
    project_id INTEGER NOT NULL REFERENCES service_projects(project_id),
    category_id INTEGER NOT NULL REFERENCES category(category_id),
    PRIMARY KEY (project_id, category_id)
);

INSERT INTO category (name) VALUES
('Environmental'),
('Educational'),
('Community Service'),
('Health and Wellness');

INSERT INTO project_category (project_id, category_id) VALUES
(1, 1),   -- Park Cleanup Day -> Environmental
(2, 3),   -- Playground Build -> Community Service
(3, 3),   -- Home Repair Blitz -> Community Service
(4, 1),   -- Trail Restoration -> Environmental
(5, 4),   -- Winter Shelter Setup -> Health and Wellness
(6, 1),   -- Community Garden Planting -> Environmental
(7, 2),   -- Compost Workshop -> Educational
(7, 1),   -- Compost Workshop also -> Environmental  (shows the many-to-many in action)
(8, 3),   -- Farmers Market Support -> Community Service
(9, 1),   -- Seed Bank Sorting -> Environmental
(10, 1),  -- Orchard Cleanup -> Environmental
(11, 2),  -- Reading Buddies Kickoff -> Educational
(12, 3),  -- Food Pantry Stocking -> Community Service
(13, 4),  -- Senior Tech Help Day -> Health and Wellness
(14, 3),  -- Coat Drive Collection -> Community Service
(15, 2);  -- Youth Mentoring Night -> Educational

CREATE TABLE roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    role_description TEXT
);
INSERT INTO roles (role_name, role_description) VALUES 
    ('user', 'Standard user with basic access'),
    ('admin', 'Administrator with full system access');

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role_id INTEGER REFERENCES roles(role_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Insert a test user
INSERT INTO users (name, email, password_hash, role_id) 
VALUES ('testuser', 'test@example.com', 'placeholder_hash', 1);

-- Join users and roles to see complete information
SELECT u.user_id, u.name, u.email, r.role_name, r.role_description
FROM users u
JOIN roles r ON u.role_id = r.role_id;

-- Delete the test user
DELETE FROM users WHERE email = 'test@example.com';
UPDATE users SET role_id = (SELECT role_id FROM roles WHERE role_name = 'admin') WHERE email = 'admin@example.com';
SELECT users.user_id, users.email, roles.role_name FROM users JOIN roles ON users.role_id = roles.role_id;

CREATE TABLE volunteers (
    user_id INTEGER NOT NULL REFERENCES users(user_id),
    project_id INTEGER NOT NULL REFERENCES service_projects(project_id),
    PRIMARY KEY (user_id, project_id)
);