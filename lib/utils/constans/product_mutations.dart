const String addProduct = """
mutation addProduct(\$title: String!, \$price: Float!, \$description: String!, \$categoryId: Float!, \$images: [String!]!) {
  addProduct(
  data: {
    title: \$title,
    price: \$price,
    description: \$description,
    categoryId: \$categoryId,
    images: \$images
  }) {
    id
    title
    price
    description
    category {
      id
      name
    }
    images
  }
}
""";

const String updateProduct = """
mutation updateProduct(\$id: ID!, \$title: String, \$price: Float, \$description: String, \$categoryId: Float) {
  updateProduct(id: \$id, changes: {
    title: \$title,
    price: \$price,
    description: \$description,
    categoryId: \$categoryId
  }) {
    id
    title
    price
    description
    category {
      name
    }
  }
}
""";

const String deleteProduct = """
mutation DeleteProduct(\$id: ID!) {
  deleteProduct(id: \$id)
}
""";
