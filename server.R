# Mock Storage do not need configuration details but does require mock data
# When using an Azure SQL Server, configuration details are needed
# Configuration details can be stored in .Reviron file and retrieved via Environment Package
configuration <- data.frame()

# storage <- configuration |> Storage::Storage(type = "memory")
# Todo.Mock.Data |> storage[['seed.table']]('Todo')

configurator <- Storage::ODBC.Configurator()
configuration <- configurator[['get.config']](type = 'Preset')
storage <- configuration |> Storage::Storage()

# Data Layer
data  <- storage |> Todo.Orchestration()

shinyServer(\(input, output, session) {
  Todo.Controller("todo", data)
})
