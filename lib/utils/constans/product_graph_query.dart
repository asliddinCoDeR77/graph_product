const String fetchProducts = """
query {
  products {
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
