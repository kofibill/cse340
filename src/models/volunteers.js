import db from './db.js';

const addVolunteer = async (userId, projectId) => {
    const query = `
        INSERT INTO volunteers (user_id, project_id)
        VALUES ($1, $2);
    `;
    await db.query(query, [userId, projectId]);
};

const removeVolunteer = async (userId, projectId) => {
    const query = `
        DELETE FROM volunteers
        WHERE user_id = $1 AND project_id = $2;
    `;
    await db.query(query, [userId, projectId]);
};

const isVolunteering = async (userId, projectId) => {
    const query = `
        SELECT 1
        FROM volunteers
        WHERE user_id = $1 AND project_id = $2;
    `;
    const result = await db.query(query, [userId, projectId]);
    return result.rows.length > 0;
};

const getVolunteeredProjectsByUserId = async (userId) => {
    const query = `
        SELECT
            sp.project_id,
            sp.title,
            sp.project_date,
            sp.location,
            o.name AS organization_name
        FROM volunteers v
        JOIN public.service_projects sp ON v.project_id = sp.project_id
        JOIN public.organization o ON sp.organization_id = o.organization_id
        WHERE v.user_id = $1
        ORDER BY sp.project_date;
    `;
    const queryParams = [userId];
    const result = await db.query(query, queryParams);
    return result.rows;
};

export { addVolunteer, removeVolunteer, isVolunteering, getVolunteeredProjectsByUserId };