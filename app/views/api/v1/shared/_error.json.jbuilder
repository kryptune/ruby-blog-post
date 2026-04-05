json.status "error"
json.code 422
json.messages object.errors.map { |error| 
  { 
    field: error.attribute, 
    message: error.message 
  } 
}