warn("Title is too short.") if github.pr_title.length < 5

git.modified_files.map do |file|
  if important_files.include?(file)
    message "#{file} has changed."
  end
end

# Swiftlint
github.dismiss_out_of_range_messages
swiftlint.config_file = '.swiftlint.yml'
swiftlint.lint_files inline_mode: true