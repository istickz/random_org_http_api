module RandomOrgHttpApi
  class Generator
    require 'net/http'
    include RandomOrgHttpApi::Configuration

    def generate_integers(params = {})
      integers_query = query('integer', params)
      request(DOMAIN, integers_query)
    end

    def generate_strings(params = {})
      strings_query = query('string', params)
      request(DOMAIN, strings_query)
    end

    def generate_sequence(params = {})
      sequence_query = query('sequence', params)
      request(DOMAIN, sequence_query)
    end

    private

    # Метод запроса на сайт random.org
    def request(domain, query)
      # Создаем запрос
      res = Net::HTTP.get_response(domain, query)
      # Если все хорошо, то возвращаем форматированный ответ,
      # если нет, то показываем ответ ошибки сервера.
      res.is_a?(Net::HTTPSuccess) ? res.body.split : res.body.strip
    end

    # Метод для генерации запроса
    def query(object_type, params)
      # Совмещаем параметры по умолчанию с параметами, который передал пользователь
      all_params = DEFAULT_QUERY_PARAMS.merge(params)
      # В зависимости от типа объекта, который нужно сгенерировать, оставляем только нужные для него параметры.
      case object_type
        when 'integer' then
          right_params = permit_params(all_params, INTEGER_QUERY_KEYS)
          insert_params(right_params, INTEGER_QUERY_TEMPLATE)
        when 'string' then
          right_params = permit_params(all_params, STRING_QUERY_KEYS)
          insert_params(right_params, STRING_QUERY_TEMPLATE)
        when 'sequence' then
          right_params = permit_params(all_params, SEQUENCE_QUERY_KEYS)
          insert_params(right_params, SEQUENCE_QUERY_TEMPLATE)
      end
    end

    # Метод оставляющий только нужные параметры.
    def permit_params(params, required_keys)
      params.select { |k| required_keys.include?(k) }
    end

    # Метод подстановки параметров в темплейт.
    # Параметры должны передаваться в хеше
    def insert_params(params, template)
      template % params
    end

  end
end