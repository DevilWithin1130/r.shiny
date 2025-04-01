# Modified to always use memory storage instead of ODBC

# Initialize with default empty configuration
configuration <- data.frame()

message("Using memory storage for application data")
storage <- configuration |> Storage::Storage(type = "memory")

# Load mock data if available
if (exists("Todo.Mock.Data")) {
  message("Loading mock data into memory storage")
  Todo.Mock.Data |> storage[['seed.table']]('Todo')
}

# Data Layer
data <- storage |> Todo.Orchestration()

shinyServer(\(input, output, session) {
  Todo.Controller("todo", data)
})
