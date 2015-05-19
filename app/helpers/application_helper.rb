module ApplicationHelper
  def flash_message
    flash_msg = ''
    if flash.blank?
      return flash_msg
    end
    flash.each do |key, value|
      flash_msg << "<div class='#{key} flash'> #{value} </div>"
    end
    flash_msg
  end
end
