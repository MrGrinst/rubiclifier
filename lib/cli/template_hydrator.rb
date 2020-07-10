require_relative "../rubiclifier.rb"

class TemplateHydrator
  attr_reader :args, :project_name
  private :args

  def initialize(args, project_name)
    @args = args
    @project_name = project_name
  end

  def hydrate(template_string)
    ERB.new(template_string, nil, "-").result(binding)
  end

  def project_name_camel_case
    @pnsc ||= project_name.split("_").collect(&:capitalize).join
  end

  def include_settings?
    args.boolean("settings")
  end

  def brew_dependencies
    args.string("homebrew")&.split(" ") || []
  end

  def uses_brew?
    !brew_dependencies.empty?
  end

  def features
    @features ||= [
      (Rubiclifier::Feature::BACKGROUND if args.boolean("background")),
      (Rubiclifier::Feature::DATABASE if (args.boolean("database") || include_settings?)),
      (Rubiclifier::Feature::IDLE_DETECTION if args.boolean("idle-detection")),
      (Rubiclifier::Feature::NOTIFICATIONS if args.boolean("notifications")),
    ].compact
  end

  def needs_setup?
    !features.empty? || uses_brew?
  end

  def feature_enabled?(feature)
    features.include?(feature)
  end
end
