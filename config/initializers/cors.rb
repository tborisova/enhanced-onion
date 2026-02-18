Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch('ALLOWED_ORIGINS').split(',')
    resource '*',
             headers: :any,
             expose: ['Authorization'],
             methods: %i[get post put patch delete options]
  end
end
