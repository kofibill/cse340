// Import any needed model functions
import { getAllCategories, getCategoriesByProjectId } from '../models/categories.js';
import { getProjectDetails } from '../models/projects.js';
import {getCategoryDetails } from '../models/categories.js';
import { getProjectsByCategoryId } from '../models/categories.js';
import { createCategory, updateCategory, updateCategoryAssignments } from '../models/categories.js';
import { body, validationResult } from 'express-validator';

// Define validation rules for category form
const categoryValidation = [
    body('name')
        .trim()
        .escape()
        .notEmpty()
        .withMessage('Category name is required')
        .isLength({ min: 3, max: 100 })
        .withMessage('Category name must be between 3 and 100 characters')
];

// Define any controller functions
const showCategoriesPage = async (req, res) => {
    const categories = await getAllCategories();
    const title = 'Service Categories';

    res.render('categories', { title, categories });
};  

const showCategoriesDetailsPage = async(req, res) =>{
    const categoryId = req.params.id;
    const categoryDetails = await getCategoryDetails(categoryId);
    const projects = await getProjectsByCategoryId(categoryId);
    const title = 'Category Details';
    res.render('category', { title, categoryDetails, projects });
}

const showAssignCategoriesForm = async (req, res) => {
    const projectId = req.params.projectId;

    const projectDetails = await getProjectDetails(projectId);
    const categories = await getAllCategories();
    const assignedCategories = await getCategoriesByProjectId(projectId);

    const title = 'Assign Categories to Project';

    res.render('assign-categories', { title, projectId, projectDetails, categories, assignedCategories });
};

const processAssignCategoriesForm = async (req, res) => {
    const projectId = req.params.projectId;
    const selectedCategoryIds = req.body.categoryIds || [];

    // Ensure selectedCategoryIds is always an array, even if only one checkbox was checked
    const categoryIdsArray = Array.isArray(selectedCategoryIds) ? selectedCategoryIds : [selectedCategoryIds];

    try {
        await updateCategoryAssignments(projectId, categoryIdsArray);
        req.flash('success', 'Categories updated successfully.');
        return res.redirect(`/project/${projectId}`);
    } catch (error) {
        console.error('Error updating category assignments:', error);
        req.flash('error', 'There was an error updating the categories for this project.');
        return res.redirect(`/assign-categories/${projectId}`);
    }
};

const showNewCategoryForm = async (req, res) => {
    const title = 'Add New Category';
    res.render('new-category', { title });
};

const processNewCategoryForm = async (req, res) => {
    const results = validationResult(req);
    if (!results.isEmpty()) {
        results.array().forEach((error) => {
            req.flash('error', error.msg);
        });
        return res.redirect('/new-category');
    }

    const { name } = req.body;

    try {
        const categoryId = await createCategory(name);
        req.flash('success', 'Category added successfully!');
        return res.redirect(`/category/${categoryId}`);
    } catch (error) {
        console.error('Error creating category:', error);
        req.flash('error', 'There was an error creating the category.');
        return res.redirect('/new-category');
    }
};

const showEditCategoryForm = async (req, res) => {
    const categoryId = req.params.id;
    const categoryDetails = await getCategoryDetails(categoryId);

    const title = 'Edit Category';
    res.render('edit-category', { title, categoryDetails });
};

const processEditCategoryForm = async (req, res) => {
    const categoryId = req.params.id;

    const results = validationResult(req);
    if (!results.isEmpty()) {
        results.array().forEach((error) => {
            req.flash('error', error.msg);
        });
        return res.redirect(`/edit-category/${categoryId}`);
    }

    const { name } = req.body;

    try {
        await updateCategory(categoryId, name);
        req.flash('success', 'Category updated successfully!');
        return res.redirect(`/category/${categoryId}`);
    } catch (error) {
        console.error('Error updating category:', error);
        req.flash('error', 'There was an error updating the category.');
        return res.redirect(`/edit-category/${categoryId}`);
    }
};
// Export any controller functions
export { showCategoriesPage, showCategoriesDetailsPage, 
    showAssignCategoriesForm, processAssignCategoriesForm,
    categoryValidation, showNewCategoryForm, processNewCategoryForm,
    showEditCategoryForm, processEditCategoryForm
};