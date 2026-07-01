module ApplicationHelper
  def scribble_button_enabled_classes
    "bg-transparent text-blue-700 border-blue-500 hover:bg-blue-500 " \
    "hover:text-white hover:border-transparent cursor-pointer"
  end

  def scribble_button_disabled_classes
    "bg-gray-200 text-gray-400 border-gray-300 cursor-not-allowed opacity-60"
  end
end
