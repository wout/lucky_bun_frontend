database_name = "bun_frontend_#{LuckyEnv.environment}"

AppDatabase.configure do |settings|
  # No database is required
  settings.credentials = Avram::Credentials.void
end

Avram.configure do |settings|
  settings.database_to_migrate = AppDatabase
end
