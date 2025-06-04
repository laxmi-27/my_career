# init.rb
Redmine::Plugin.register :my_career do
  name 'Career Page Plugin'
  author 'Your Name'
  description 'This plugin adds a career page with qualification, experience, position fields.'
  version '0.0.1'
  url 'http://example.com/my_career'
  author_url 'http://example.com'

  menu :top_menu, :career_page, { controller: 'career', action: 'new' }, caption: 'Career', after: :projects
end
