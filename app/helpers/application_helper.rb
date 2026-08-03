module ApplicationHelper
  BUTTON_STYLES = {
    secondary: "px-5 py-2.5 text-base font-semibold border-2 border-brand-primary text-ui-text  hover:bg-brand-primary/20 rounded-theme-md shadow-sm transition-colors duration-300 ease-in-out cursor-pointer",
    primary: "px-6 py-2.5 text-base bg-brand-primary text-ui-bg font-semibold rounded-theme-md shadow-sm hover:opacity-90 transition-colors duration-300 ease-in-out cursor-pointer"
  }.freeze


  def scribble_button_enabled_classes
    "bg-transparent" \
    "bg-brand-primary  hover:border-transparent cursor-pointer"
  end

  def scribble_button_disabled_classes
    "bg-brand-primary/30 border-gray-300 cursor-not-allowed transition-all"
  end

  def flash_class(type)
    case type.to_sym
    when :notice
      "bg-green-50 border-green-200 text-green-800"
    when :alert
      "bg-red-50 border-red-200 text-red-800"
    else
      "bg-blue-50 border-blue-200 text-blue-800"
    end
  end

  def button_classes(variant = :secondary, extra_classes = "")
    "#{BUTTON_STYLES.fetch(variant, BUTTON_STYLES[:secondary])} #{extra_classes}".strip
  end

  def tip_message(content = nil, extra_classes: "", **options, &block)
    base_classes = "text-sm text-gray-text"
    combined_classes = "#{base_classes} #{extra_classes}".strip

    tag.p(content, class: combined_classes, **options, &block)
  end

  def circle_btn_classes(options = {})
    # 1. Grab your size and color options or fall back to defaults
    size       = options[:size] || "w-9 h-9"
    bg_color   = options[:bg] || "bg-brand-primary hover:bg-brand-primary/60"
    text_color = options[:text] || "text-ui-bg"


    # 2. Combine the structural base with the customization classes
    base = "flex stroke-0 fill-current items-center justify-center rounded-full transition-all duration-200 shadow-sm"

    "#{base} #{size} #{bg_color} #{text_color} #{options[:extra]} cursor-pointer"
  end
end
