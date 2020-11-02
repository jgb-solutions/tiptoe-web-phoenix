alias TipToe.Repo
alias TipToe.Utils
alias TipToe.User
alias TipToe.Category
alias TipToe.Photo
alias TipToe.Model

categories = [
  "Compas (Konpa)",
  "Roots (Rasin)",
  "Reggae",
  "Yanvalou",
  "R&B",
  "Rap",
  "Rap Kreyòl",
  "Dancehall",
  "Other",
  "Carnival",
  "Gospel",
  "DJ",
  "Mixtape",
  "Rabòday",
  "Rara",
  "Reggaeton",
  "House",
  "Jazz",
  "Raga",
  "Soul",
  "Sanba",
  "Sanmba",
  "Rock & Roll",
  "Techno",
  "Slow",
  "Salsa",
  "Troubadour",
  "Riddim",
  "Afro",
  "Slam"
]

photo_urls = [
  "1.jpg",
  "2.jpg",
  "3.jpg",
  "4.jpg"
]

# Users
Repo.delete_all(User)

users = [
  %{
    name: "Jean Gérard",
    email: "jgbneatdesign@gmail.com",
    password: Bcrypt.hash_pwd_salt("asdf,,,"),
    admin: true,
    telephone: "41830318"
  }
]

Enum.each(users, fn user ->
  Repo.insert!(%User{
    name: user.name,
    email: user.email,
    password: user.password,
    admin: user.admin,
    telephone: user.telephone
  })
end)

IO.puts("Users table seeded!")

# Categories
Repo.delete_all(Category)

Enum.each(categories, fn categorie ->
  Repo.insert!(%Category{
    name: categorie,
    slug: Slugger.slugify_downcase(categorie)
  })
end)

IO.puts("Categories table seeded!")

if Mix.env() == :dev do
  # Models
  Repo.delete_all(Model)

  Enum.each(1..100, fn _i ->
    username = Faker.Internet.user_name()

    Repo.insert!(%Model{
      name: Faker.Name.name(),
      stage_name: Faker.Name.name(),
      poster: "models/image-" <> Integer.to_string(Enum.random(1..66)) <> ".png",
      hash: Utils.get_hash(Model),
      user_id: User.random().id,
      bio: Faker.Lorem.paragraph(),
      facebook: username,
      twitter: username,
      youtube: username,
      instagram: username,
      img_bucket: "img-storage-dev.tiptoe.app"
    })
  end)

  IO.puts("Models table seeded!")

  # Photo
  Repo.delete_all(Photo)

  Enum.each(1..500, fn _i ->
    Repo.insert!(%Photo{
      caption: Faker.Name.name(),
      hash: Utils.get_hash(Photo),
      detail: Faker.Lorem.paragraph(5),
      uri: "photos/" <> Enum.random(photo_urls),
      user_id: User.random().id,
      model_id: Model.random().id,
      category_id: Category.random().id,
      img_bucket: "img-storage-dev.tiptoe.app"
      # inserted_at: $inserted_at,
      # updated_at: $updated_at,
    })
  end)

  IO.puts("Photo table seeded!")
end
