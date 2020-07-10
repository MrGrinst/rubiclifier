require_relative "../rubiclifier.rb"

class RubiclifierCli < Rubiclifier::BaseApplication
  attr_reader :project_name
  private :project_name

  def show_help
    puts
    puts("rubiclifier helps you generate new Ruby CLI and background service tools")
    puts
    puts("Usage:")
    puts("  rubiclifier --help                              | Shows this help menu")
    puts("  rubiclifier new [project_name]                  | Creates a new rubiclifier project")
    puts("                   --background                   |   Generate with background service setup steps")
    puts("                   --database                     |   Generate with a persistent database")
    puts('                   --homebrew "[first [second]]"  |   Require specific homebrew kegs')
    puts("                   --idle-detection               |   Generate with ability to detect if user is idle")
    puts("                   --notifications                |   Generate with notification functionality")
    puts("                   --settings                     |   Generate with persistent setting functionality")
    puts
    exit
  end

  def run_application
    case args.command
    when "new"
      create_project
    else
      show_help
    end
  end

  private

  def create_project
    @project_name = args.first_option
    validate_project_name
    system("mkdir -p #{project_name}")
    system("cp -R \"#{File.dirname(__FILE__)}/../../project_template/.\" #{project_name}")
    system("cp \"#{File.dirname(__FILE__)}/../../project_template/.gitignore\" #{project_name}")
    Dir.glob("#{project_name}/**/*.erb").each do |template_file|
      hydrate_template_file(template_file)
      system("mv #{template_file} #{template_file.sub(/\.erb$/, "").sub("PROJECT_NAME", project_name)}")
    end
    unless template_hydrator.feature_enabled?(Rubiclifier::Feature::DATABASE)
      system("rm #{project_name}/migrations.rb")
    end
    puts("Finished creating project #{project_name}! Build out the application in #{project_name}/lib/#{project_name}.rb".green)
  end

  def validate_project_name
    if project_name.nil?
      puts("You must specify a project name.".red)
      exit
    elsif !project_name.match(/^[a-z_]+$/)
      puts("Your project name must be lowercase letters and _".red)
      exit
    end
  end

  def hydrate_template_file(template_file)
    template_string = File.read(template_file)
    output = template_hydrator.hydrate(template_string)
    File.write(template_file, output)
  end

  def template_hydrator
    @template_hydrator ||= TemplateHydrator.new(args, project_name)
  end
end
