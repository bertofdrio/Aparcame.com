Paperclip.interpolates :number do |attachment, style|
  attachment.instance.number
end

Paperclip.interpolates :photoble_type do |attachment, style|
    attachment.instance.photoble_type
end

Paperclip.interpolates :photoble_id do |attachment, style|
  attachment.instance.photoble_id
end