context("basic functionality")
pet_api <- PetApi$new()
pet_id <- 123321
pet <- Pet$new("name_test",
  photoUrls = list("photo_test", "second test"),
  category = Category$new(id = 450, name = "test_cat"),
  id = pet_id,
  tags = list(
    Tag$new(id = 123, name = "tag_test"), Tag$new(id = 456, name = "unknown")
  ),
  status = "available"
)
result <- pet_api$AddPet(pet)

test_that("AddPet", {
  expect_equal(pet_id, 123321)
  #expect_equal(result, NULL)
})

test_that("Test toJSON toJSON fromJSON fromJSONString", {
  pet0 <- Pet$new()
  jsonpet <- pet0$toJSON()
  pet2 <- pet0$fromJSON(
    jsonlite::toJSON(jsonpet, auto_unbox = TRUE)
  )
  expect_equal(pet0, pet2)
  jsonpet <- pet0$toJSONString()
  pet2 <- pet0$fromJSON(
    jsonpet
  )
  expect_equal(pet0, pet2)

  jsonpet <- pet0$toJSONString()
  pet2 <- pet0$fromJSONString(
    jsonpet
  )
  expect_equal(pet0, pet2)

  pet1 <- Pet$new("name_test",
    list("photo_test", "second test"),
    category = Category$new(id = 450, name = "test_cat"),
    id = pet_id,
    tags = list(
      Tag$new(id = 123, name = "tag_test"), Tag$new(id = 456, name = "unknown")
    ),
    status = "available"
  )
  jsonpet <- pet1$toJSON()
  pet2 <- pet1$fromJSON(
    jsonlite::toJSON(jsonpet, auto_unbox = TRUE)
  )
  expect_equal(pet1, pet2)

  jsonpet <- pet1$toJSONString()
  pet2 <- pet1$fromJSON(
    jsonpet
  )
  expect_equal(pet1, pet2)

  jsonpet <- pet1$toJSONString()
  pet2 <- pet1$fromJSONString(
    jsonpet
  )
  expect_equal(pet1, pet2)
})

test_that("Test Category", {
  c1 <- Category$new(id = 450, name = "test_cat")
  c2 <- Category$new()
  c2$fromJSON(jsonlite::toJSON(c1$toJSON(), auto_unbox = TRUE))
  expect_equal(c1, c2)
  c2$fromJSONString(c1$toJSONString())
  expect_equal(c1, c2)
})

test_that("GetPetById", {
  response <- pet_api$GetPetById(pet_id)
  expect_equal(response$id, pet_id)
  expect_equal(response$name, "name_test")
  expect_equal(
    response$photoUrls,
    list("photo_test", "second test")
  )
  expect_equal(response$status, "available")
  expect_equal(response$category, Category$new(id = 450, name = "test_cat"))

  expect_equal(pet$tags, response$tags)
  expect_equal(
    response$tags,
    list(Tag$new(id = 123, name = "tag_test"), Tag$new(id = 456, name = "unknown"))
  )
})

test_that("GetPetById with data_file", {
  # test to ensure json is saved to the file `get_pet_by_id.json`
  pet_response <- pet_api$GetPetById(pet_id, data_file = "get_pet_by_id.json")
  response <- read_json("get_pet_by_id.json")
  expect_true(!is.null(response))
  expect_equal(response$id, pet_id)
  expect_equal(response$name, "name_test")
})

test_that("Tests allOf", {
  # test allOf without discriminator
  a1 <- AllofTagApiResponse$new(id = 450, name = "test_cat", code = 200, type = "test_type", message = "test_message")
  
  expect_true(!is.null(a1))
  expect_equal(a1$id, 450)
  expect_equal(a1$name, "test_cat")
})

test_that("Tests allOf with discriminator", {
  # test allOf without discriminator
  c1 <- Cat$new(className = "cat", color = "red", declawed = TRUE)
  
  expect_true(!is.null(c1))
  expect_equal(c1$className, "cat")
  expect_equal(c1$color, "red")
  expect_true(c1$declawed)
})

test_that("Tests validateJSON", {
  json <-
  '{"name": "pet", "photoUrls" : ["http://a.com", "http://b.com"]}'
  
  json2 <-
  '[
    {"Name" : "Tom", "Age" : 32, "Occupation" : "Consultant"}, 
    {},
    {"Name" : "Ada", "Occupation" : "Engineer"}
  ]'

  # validate `json` and no error throw
  Pet$public_methods$validateJSON(json)

  # validate `json2` and should throw an error due to missing required fields
  #expect_error(Pet$public_methods$validateJSON(json2), 'The JSON input ` [\n    {\"Name\" : \"Tom\", \"Age\" : 32, \"Occupation\" : \"Consultant\"}, \n    {},\n    {\"Name\" : \"Ada\", \"Occupation\" : \"Engineer\"}\n  ] ` is invalid for Pet: the required field `name` is missing.')
  
})

test_that("Tests oneOf", {
  basque_pig_json <-
  '{"className": "BasquePig", "color": "red"}'

  danish_pig_json <-
  '{"className": "DanishPig", "size": 7}'

  wrong_json <- 
  '[
    {"Name" : "Tom", "Age" : 32, "Occupation" : "Consultant"}, 
    {},
    {"Name" : "Ada", "Occupation" : "Engineer"}
  ]'

  pig <- Pig$new()
  danish_pig <- pig$fromJSON(danish_pig_json)
  expect_equal(danish_pig$actual_type, "DanishPig")
  expect_equal(danish_pig$actual_instance$size, 7)
  expect_equal(danish_pig$actual_instance$className, "DanishPig")

  basque_pig <- pig$fromJSON(basque_pig_json)
  expect_equal(basque_pig$actual_type, "BasquePig")
  expect_equal(basque_pig$actual_instance$color, "red")
  expect_equal(basque_pig$actual_instance$className, "BasquePig")

  #expect_error(pig$fromJSON(wrong_json), "No match found when deserializing the payload into Pig with oneOf schemas BasquePig, DanishPig. Details:  The JSON input ` [\n    {\"Name\" : \"Tom\", \"Age\" : 32, \"Occupation\" : \"Consultant\"}, \n    {},\n    {\"Name\" : \"Ada\", \"Occupation\" : \"Engineer\"}\n  ] ` is invalid for BasquePig: the required field `className` is missing., The JSON input ` [\n    {\"Name\" : \"Tom\", \"Age\" : 32, \"Occupation\" : \"Consultant\"}, \n    {},\n    {\"Name\" : \"Ada\", \"Occupation\" : \"Engineer\"}\n  ] ` is invalid for DanishPig: the required field `className` is missing.")
  expect_error(pig$fromJSON('{}'), 'No match found when deserializing the payload into Pig with oneOf schemas BasquePig, DanishPig. Details:  The JSON input ` \\{\\} ` is invalid for BasquePig: the required field `className` is missing\\., The JSON input ` \\{\\} ` is invalid for DanishPig: the required field `className` is missing\\.')

})

#test_that("GetPetById", {
#  pet.id <- pet.id
#  pet <- Pet$new(pet.id, NULL, "name_test2",
#                 list("photo_test2", "second test2"),
#                 NULL, NULL)
#  result <-pet_api$AddPet(pet)
#
#  response <- pet_api$GetPetById(pet.id)
#
#  expect_equal(response$id, pet.id)
#  expect_equal(response$name, "name_test2")
#  #expect_equal(response$category, Category$new(450,"test_cat"))
#  expect_equal(response$photoUrls, list("photo_test2", "second test2"))
#  expect_equal(response$status, NULL)
#  #expect_equal(response$tags, list(Tag$new(123, "tag_test"), Tag$new(456, "unknown")))
#})

#test_that("updatePetWithForm", {
#  response <- pet_api$updatePetWithForm(pet_id, "test", "sold")
#  expect_equal(response, "Pet updated")
#})
