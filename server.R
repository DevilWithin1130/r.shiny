# Connection configuration can come from environment variables (Docker) or preset configuration

# Initialize with default empty configuration
configuration <- data.frame()

# Check if we're in Docker environment
if (Sys.getenv("DOCKER_ENV") == "true") {
  # In Docker: Use environment variables
  message("Running in Docker environment, using environment variables for database connection")
  
  # Get DB configuration from environment variables
  db_config <- list(
    driver = Sys.getenv("DB_DRIVER"),
    server = Sys.getenv("DB_SERVER"),
    database = Sys.getenv("DB_NAME"),
    uid = Sys.getenv("DB_USER"),
    pwd = Sys.getenv("DB_PASSWORD"),
    port = Sys.getenv("DB_PORT", "1433")
  )
  
  # Only attempt DB connection if server is specified
  if (db_config$server != "") {
    tryCatch({
      configuration <- as.data.frame(db_config)
      storage <- configuration |> Storage::Storage(type = "odbc")
      message("Successfully connected to database via environment variables")
    }, error = function(e) {
      message("Error connecting to database: ", e$message)
      message("Falling back to memory storage")
      configuration <- data.frame()
      storage <- configuration |> Storage::Storage(type = "memory")
      # Optionally seed with mock data
      if (exists("Todo.Mock.Data")) {
        Todo.Mock.Data |> storage[['seed.table']]('Todo')
      }
    })
  } else {
    message("No database server specified. Using memory storage.")
    storage <- configuration |> Storage::Storage(type = "memory")
    # Optionally seed with mock data
    if (exists("Todo.Mock.Data")) {
      Todo.Mock.Data |> storage[['seed.table']]('Todo')
    }
  }
} else {
  # Local development: Use preset configuration
  tryCatch({
    configurator <- Storage::ODBC.Configurator()
    configuration <- configurator[['get.config']](type = 'Preset')
    storage <- configuration |> Storage::Storage()
    message("Using preset configuration")
  }, error = function(e) {
    message("Error with preset configuration: ", e$message)
    message("Falling back to memory storage")
    configuration <- data.frame()
    storage <- configuration |> Storage::Storage(type = "memory")
    # Optionally seed with mock data
    if (exists("Todo.Mock.Data")) {
      Todo.Mock.Data |> storage[['seed.table']]('Todo')
    }
  })
}

# Data Layer
data <- storage |> Todo.Orchestration()

shinyServer(\(input, output, session) {
  Todo.Controller("todo", data)
})
