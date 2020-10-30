alias TipToe.Repo
alias TipToe.Utils
alias TipToe.User
alias TipToe.Category
alias TipToe.Photo
alias TipToe.Model

model_posters = [
  "p06b4ktw.jpg",
  "_2Xp8Hde_400x400.png",
  "p01bqgmc.jpg",
  "p05kdhc3.jpg",
  "256x256.jpg",
  "GettyImages-521943452-e1527600573393-256x256.jpg",
  "oU7C04AF_400x400.jpg",
  "SM9t8paa_400x400.jpg",
  "p01br7j4.jpg",
  "181121-Daly-Tekashi-6ix9ine-tease_wpljyq.jpeg",
  "256.jpg",
  "p023cxqn.jpg",
  "p01bqlzy.jpg",
  "culture1.jpg",
  "Tyga-Molly-256x256.jpg",
  "GettyImages-599438124-256x256.jpg",
  "bLVTjpR4_400x400.jpg",
  "p01br530.jpg",
  "Kfd0NPizaV8FW0vyIBzHn_xs822K-jHgxZYT-S7Znmc.jpg",
  "55973d5d0a44d8d36a8b09607abbf70a.jpg",
  "GettyImages-2282702_l75xht (1).jpeg",
  "p01br58s.jpg",
  "p049twzl.jpg",
  "247664528009202.jpg"
]

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

photo_posters = [
  "cover256x256-558f05a20d704c239b77f8d806886464.jpg",
  "cover256x256-4de6dd257b8347e7bebe00b3b4630b71.jpg",
  "cover256x256-bd6bca6cfcae4825ab8e40ff2ea89596.jpg",
  "3ded8e0edc080f07a3a80ba5354d3ee7.jpg",
  "cover256x256-b82dac25a8fc4522b5cee417c8f9c414.jpg",
  "cover256x256-69a4662389e44c9e8f13b1ae8868d9b7.jpg",
  "cover256x256-3786d418d27f41378cb17b94a1890a50.jpg",
  "cover256x256-a97367ecb2c44ced9f722edd7c37414b.jpg",
  "cover256x256-7b82a27d2bf94279800b5d1f1e4077c4.jpg",
  "cover256x256-888b684ae24d47b79f4f55d66dc8cb40.jpg",
  "51ri1Ho8s5L._AA256_.jpg",
  "cover256x256-e3f35413861645bf921926f04fdd7499.jpg",
  "cover256x256-26048aee74bc4dc7b21a9a02295ad546.jpg",
  "a327310e6620b5f6d6dc3c0875d8b528.jpg",
  "0ba78f0b96c90599c04693c1faed92c7.jpg",
  "weebie.jpeg",
  "cover256x256-2df51bf5cf51437691ed27ca7e1981df.jpg",
  "apa7remqyqce2xx87c18.jpeg",
  "5820f738b9bdcdcde097aa9334e5c00a.jpg",
  "616j6KySGPL._AA256_.jpg",
  "1357828077_uploaded.jpg",
  "download3.jpeg",
  "Pu5fUTwO_400x400.jpg",
  "image.jpg"
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
      poster: "models/" <> Enum.random(model_posters),
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
      uri: "photos/" <> Enum.random(photo_posters),
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
