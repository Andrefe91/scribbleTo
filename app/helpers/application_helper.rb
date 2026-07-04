module ApplicationHelper
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
