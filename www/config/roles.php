<?php

$wp_user_roles = array (
  'administrator' =>
  array (
    'name' => 'Administrator',
    'capabilities' =>
    array (
      'switch_themes' => true,
      'edit_themes' => true,
      'edit_theme_options' => true,
      'activate_plugins' => true,
      'edit_plugins' => true,
      'edit_users' => true,
      'edit_files' => true,
      'manage_options' => true,
      'moderate_comments' => true,
      'manage_categories' => true,
      'manage_links' => true,
      'upload_files' => true,
      'import' => true,
      'edit_posts' => true,
      'edit_others_posts' => true,
      'edit_published_posts' => true,
      'publish_posts' => true,
      'edit_pages' => true,
      'read' => true,
      'level_10' => true,
      'level_9' => true,
      'level_8' => true,
      'level_7' => true,
      'level_6' => true,
      'level_5' => true,
      'level_4' => true,
      'level_3' => true,
      'level_2' => true,
      'level_1' => true,
      'level_0' => true,
      'list_users' => true,
      'edit_others_pages' => true,
      'edit_published_pages' => true,
      'publish_pages' => true,
      'delete_pages' => true,
      'delete_others_pages' => true,
      'delete_published_pages' => true,
      'delete_posts' => true,
      'delete_others_posts' => true,
      'delete_published_posts' => true,
      'delete_private_posts' => true,
      'edit_private_posts' => true,
      'read_private_posts' => true,
      'delete_private_pages' => true,
      'edit_private_pages' => true,
      'read_private_pages' => true,
      'delete_users' => true,
      'create_users' => true,
      'remove_users' => true,
      'add_users' => true,
      'promote_users' => true,
      'export' => true,
    ),
  ),
  'editor' =>
  array (
    'name' => 'Editor',
    'capabilities' =>
    array (
      'moderate_comments' => true,
      'manage_categories' => true,
      'manage_links' => true,
      'upload_files' => true,
      'edit_posts' => true,
      'edit_others_posts' => true,
      'edit_published_posts' => true,
      'publish_posts' => true,
      'edit_pages' => true,
      'read' => true,
      'level_7' => true,
      'level_6' => true,
      'level_5' => true,
      'level_4' => true,
      'level_3' => true,
      'level_2' => true,
      'level_1' => true,
      'level_0' => true,
      'edit_others_pages' => true,
      'edit_published_pages' => true,
      'publish_pages' => true,
      'delete_pages' => true,
      'delete_others_pages' => true,
      'delete_published_pages' => true,
      'delete_posts' => true,
      'delete_others_posts' => true,
      'delete_published_posts' => true,
      'delete_private_posts' => true,
      'edit_private_posts' => true,
      'read_private_posts' => true,
      'delete_private_pages' => true,
      'edit_private_pages' => true,
      'read_private_pages' => true,
    ),
  ),
  'author' =>
  array (
    'name' => 'Author',
    'capabilities' =>
    array (
      'upload_files' => true,
      'edit_posts' => true,
      'edit_published_posts' => true,
      'publish_posts' => true,
      'read' => true,
      'level_2' => true,
      'level_1' => true,
      'level_0' => true,
      'delete_posts' => true,
      'delete_published_posts' => true,
    ),
  ),
  'contributor' =>
  array (
    'name' => 'Contributor',
    'capabilities' =>
    array (
      'edit_posts' => true,
      'read' => true,
      'level_1' => true,
      'level_0' => true,
      'delete_posts' => true,
    ),
  ),
  
	'pmc-editorial-manager' => array(
		'type' => 'manager',
		'label' => 'PMC Editorial Manager',
		'base_role' => 'editor',
		'additional_capabilities' => array(
			'list_users' => true,
			'edit_themes' => true, /* Allow Appearance menu */
			'edit_posts' => true, /* Polldaddy v2.0.23 is_author() */
			'delete_others_pages' => true /* Polldaddy v2.0.23 is_editor() */
		),
	),
	'pmc-adops-manager' => array(
		'type' => 'manager',
		'label' => 'PMC AdOps Manager',
		'base_role' => 'editor',
		'additional_capabilities' => array(
			'upload_files' => true /* Specifically allow access to media tab */
		),
	),
	'pmc-reporter' => array(
		'type' => 'reporter',
		'label' => 'PMC Reporter',
		'base_role' => 'editor',
		'additional_capabilities' => array(),
	),
  
);




