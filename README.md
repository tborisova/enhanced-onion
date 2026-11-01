### Enhanced onion

This is the backend for enhanced curry

### Run

```
bundle install

bin/rake db:migrate # runs migrations

bin/rake db:seed # runs seeds

```

### Start

To start the application so that the mobile app can make queries, use:

```
bin/rails s -b 0.0.0.0
```

## Aim

This is the backend for **Curry on Mars** (internal names: "Enhanced Onion", the backend for "Enhanced Curry"), a **personal recipe keeper**. Users keep all their recipes in one private place, whatever form they came in:

- **Photo:** a picture of a recipe, such as a cookbook page. It's stored as an image; nothing reads or extracts the text.
- **Link:** a URL to a recipe online.
- **Manual:** a typed recipe with ingredients and quantities.

Users can organise recipes by category and dietary type (meat, vegetarian, vegan), and search them by title. Recipes are private to each user; there are no social or sharing features.

**Business model:** it's set up as freemium, but **billing doesn't exist yet**. Plans limit how many recipes and photos a user can store, and new users get a limited plan. The web UI says upgrades are coming ("Billing's still simmering on the stove"). For now, an admin assigns plans by hand. An `is_free` plan actually means *unlimited*, not the basic tier.

The product has three surfaces:

- **Mobile app:** the original client, in a separate repo.
- **Web app:** `app.curryonmars.com`, a newer addition. It can browse and add recipes, but not edit or delete them.
- **Admin panel:** manages users, plans, recipes, categories, dietary preferences and temporary images. Admins can also suspend users.

## Used technologies

| Area | Technology |
|---|---|
| Language and framework | Ruby 3.3.0, Rails 7.1.4 (API mode, with server-rendered pages added back) |
| Mobile API | GraphQL (`graphql-ruby` 2.3) with Dataloader batching |
| Database | PostgreSQL (the `sqlite3` gem is a leftover) |
| Web and admin UI | ERB, Tailwind via CDN, Google Fonts (Kalam, Nunito), Pagy for pagination |
| Authentication | Devise, signed JWTs (`devise-jwt`), emailed magic links, Sign in with Apple (`json-jwt`, Faraday) |
| File storage | Active Storage on Cloudflare R2 (S3-compatible), local disk in development |
| Email | Resend |
| Protection | `rack-attack` rate limiting, `rack-cors` |
| Monitoring | Honeybadger |
| Server and deployment | Puma, multi-stage Docker image; no hosting config in the repo |
| Testing | RSpec and FactoryBot, covering only the three recipe services |

## Design

**Structure:** one Rails app (a modular monolith) with three entry points that share the same models and services.

```
Mobile app ── JWT ────────▶ /graphql, /uploads ─┐
Web browser ── session ───▶ Web:: controllers ──┼─▶ Services ─▶ Models ─▶ PostgreSQL
Admin browser ── session ─▶ Admin:: controllers ┘   (Create/Edit/       └▶ Cloudflare R2
                                                     DeleteRecipe)
```

**Data model**

- A `User` belongs to a `Plan` and has many `Recipe`s.
- `Ingredient` and `Category` are shared by all users and linked to recipes through join tables. Quantity is stored on the recipe–ingredient link.
- A `Recipe` can have one photo and one `DietaryPreference`.
- `TemporaryRecipeImage` holds a photo uploaded before its recipe is saved.

**Authentication**

- Passwords are random and never shown; users sign in by magic link or Apple. Signing in with a new email creates the account.
- Magic-link tokens last 15 minutes and are cleared once used.
- Links open differently per surface: mobile uses a deep link (`curryonmars://login?token=…`), while web and admin use `/callback` URLs.
- Mobile gets a 2-week JWT, while web and admin use cookie sessions. Admin access also requires the `admin` flag.
