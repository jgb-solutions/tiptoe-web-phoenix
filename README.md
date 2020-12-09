# TipToe

To run migration in docker:

# Local

DATABASE_URL=ecto://jeangerard:asdf,,,@localhost/tiptoe_prod SECRET_KEY_BASE="pmXOigSHtxhqwd9t9JDen3mg+UEGwofWmI5hyiVPAqZsF92BD2Syybq7FaDtG2fd" \_build/prod/rel/tiptoe/bin/tiptoe eval "TipToe.Release.migrate"

# Prod

bin/tiptoe eval "TipToe.Release.migrate"

To run seed in docker:

# Local

DATABASE_URL=ecto://jeangerard:asdf,,,@localhost/tiptoe_prod SECRET_KEY_BASE="pmXOigSHtxhqwd9t9JDen3mg+UEGwofWmI5hyiVPAqZsF92BD2Syybq7FaDtG2fd" \_build/prod/rel/tiptoe/bin/tiptoe eval "TipToe.Release.seed"

# Prod

bin/tiptoe eval "TipToe.Release.seed"

To run from Docker:
docker run --network host --name="tiptoe" --restart always --env SECRET_KEY_BASE=Rcn1irdCzqk2HRiMt7apey+PYvYnq2mecWlnAIZ+55cmWKnTfjt1pwq5zHWcGpai --env PORT=4000 --env DATABASE_URL=ecto://tiptoe:tiptoeg@localhost/tiptoe -d jgbsolutions/tiptoe:0.0.1

To log into the Docker container:
docker exec -it tiptoe /bin/ash
