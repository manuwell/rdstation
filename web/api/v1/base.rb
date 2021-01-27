class Web::Api::V1::Base < Sinatra::Base
  disable :protection
  disable :show_exceptions
  disable :raise_errors

  before do
    env['x-request-id'] = SecureRandom.uuid
  end

  not_found do
    json_error_response(404, 'Page not found')
  end

  error do
    byebug
    logger.error "Something went wrong: #{env}"
    json_error_response(500, 'Something went wrong')
  end

  protected

  def json_error_response(status_code, errors)
    halt status_code, json_response_body(:failure, errors, nil)
  end

  def json_success_response(status_code, data)
    halt status_code, json_response_body(:success, [], data)
  end

  def json_pagination_response(status_code, objects)
    halt status_code, json_response_body(:success, [], data)
  end

  def json_pagination_body(objects, serializer, status = :ok)
    {
      pagination: {
        found: objects.total_count,
        pages: objects.total_pages,
        current_page: objects.current_page,
        per_page: objects.limit_value
      },
      entries: serialize_array(objects, serializer)
    }
  end

  def json_response_body(result, messages, data)
    if !%w(success failure).include?(result.to_s)
      result = 'failure'
    end

    json({
      result: result,
      request_id: env['x-request-id'] || nil,
      messages: normalize_messages(messages),
      data: data
    })
  end

  # always try to return an Array of plain strs
  def normalize_messages(messages)
    if messages.kind_of?(String)
      [messages]
    elsif messages.kind_of?(Array)
      messages.map { |m| normalize_messages(m) }.flatten
    elsif messages.kind_of?(Hash)
      messages.keys.map do |key|
        value = messages[key]
        '%s %s' % [key, normalize_messages(value).join(',')]
      end
    else
      [messages.to_s]
    end
  end
end
