module ApplicationHelper
  BUTTON_STYLES = {
    secondary: "px-5 py-2.5 text-base font-semibold border-2 border-grey-3 text-grey-6 bg-gray-100 hover:bg-grey-2 rounded-theme-md shadow-sm transition-colors cursor-pointer",
    primary: "px-6 py-2.5 text-base bg-brand-primary text-ui-bg font-semibold rounded-theme-md shadow-sm hover:opacity-90 transition-opacity cursor-pointer"
  }.freeze


  def scribble_button_enabled_classes
    "bg-transparent text-blue-700 border-blue-500 hover:bg-blue-500 " \
    "hover:text-white hover:border-transparent cursor-pointer"
  end

  def scribble_button_disabled_classes
    "bg-gray-200 text-gray-400 border-gray-300 cursor-not-allowed opacity-60"
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

  def circle_btn_classes(options = {})
    # 1. Grab your size and color options or fall back to defaults
    size       = options[:size] || "w-9 h-9"
    bg_color   = options[:bg] || "bg-gray-100 hover:bg-gray-200"
    text_color = options[:text] || "text-gray-700"

    # 2. Combine the structural base with the customization classes
    base = "flex items-center justify-center rounded-full transition-all duration-200 shadow-sm"

    "#{base} #{size} #{bg_color} #{text_color} #{options[:extra]} cursor-pointer"
  end
end
