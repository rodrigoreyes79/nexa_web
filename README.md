# NexaUno website

Marketing + legal website for **NexaUno** (nexa.uno) — *Fintech solutions for modern businesses*.
Bilingual (English / Spanish), built with **Hugo Extended**, designed to satisfy payment-processor
onboarding (Stripe, Mollie).

---

## Quick start

Hugo runs inside a Fedora **toolbox** container named `nexa` (this machine is Silverblue).
That toolbox and Hugo are already set up. If you ever need to recreate it:

```bash
toolbox create --assumeyes nexa
toolbox run --container nexa sudo dnf install -y hugo libatomic
toolbox run --container nexa bash -lc 'cd '"$PWD"' && npm install'   # Tailwind CSS v4 toolchain
```

> Styling uses **Tailwind CSS v4** (via Hugo's built-in `css.TailwindCSS`). The Tailwind CLI runs
> from `node_modules`, so `npm install` must have been run inside the toolbox. `libatomic` is required
> for Node to run in the container.

### Preview locally (live reload)

```bash
./serve.sh
# open http://localhost:1313      (English)
#      http://localhost:1313/es/  (Spanish)
```

### Production build

```bash
./build.sh        # outputs static site to ./public
```

---

## Project structure

```
hugo.toml                # site config: domain, languages, menus, business identity
i18n/{en,es}.toml        # UI strings (nav, footer, buttons)
content/en/ , content/es/
  _index.md              # homepage (hero/services/steps content lives in front matter)
  services.md pricing.md about.md contact.md
  legal/                 # aviso-legal, privacy, cookies, terms, refunds
layouts/                 # HTML templates (base, header, footer, home, services, pricing, contact)
assets/css/main.css      # Tailwind v4 theme: @theme tokens + @apply component classes
assets/js/main.js        # mobile nav toggle
package.json             # Tailwind CSS v4 toolchain (tailwindcss, @tailwindcss/cli)
static/                  # favicon.svg, robots.txt
deploy/                  # Caddyfile + deploy.sh for the Hetzner VPS
```

Most copy is editable in the Markdown front matter — no template edits needed for routine changes.

---

## Before you go live — checklist

These are what make the difference for **Stripe / Mollie** approval and legal compliance.

- [ ] **Domain + HTTPS live.** Point `nexa.uno` DNS at the Hetzner VPS; Caddy issues SSL automatically.
- [ ] **Working contact form.** Right now the form falls back to opening an email. To make it actually
      send, create a free endpoint at <https://formspree.io> (or your own handler) and set
      `formAction:` in `content/en/contact.md` and `content/es/contact.md`, then rebuild.
      The visible `rodrigo@nexa.uno` email is what processors mainly look for — that is already in place.
- [ ] **Review the legal pages.** They are solid starting templates with your real identity
      (Rodrigo Reyes, NIF Z1837378M, Av. Lazarejo 86…). Have a *gestoría*/lawyer review them, and bump
      `legalUpdated` in `hugo.toml` when you do.
- [ ] **Confirm pricing.** Tiers in `pricing.md` are placeholders (€49 / €149 / Custom). Adjust to real
      numbers — Stripe/Mollie like to see clear pricing, but it does not have to be final.
- [ ] **Business name consistency.** The site uses the trade name *NexaUno* and the legal name
      *Rodrigo Reyes*. Use the **same legal name + NIF** when registering with the processor.
- [ ] **Email on your domain.** Set up `rodrigo@nexa.uno` (or `hello@/info@`) so processor emails reach you.

---

## Deploy to the Hetzner VPS

Recommended web server: **Caddy** (automatic Let's Encrypt HTTPS, zero cert hassle).

**One-time, on the server:**

1. Install Caddy (commands are in `deploy/Caddyfile`).
2. Create the web root: `sudo mkdir -p /var/www/nexa`
3. Copy `deploy/Caddyfile` to `/etc/caddy/Caddyfile`, then `sudo systemctl reload caddy`.
4. Point DNS: an `A` record for `nexa.uno` (and `www`) → your VPS IP.

**Each deploy, from your machine:**

```bash
./deploy/deploy.sh root@YOUR_SERVER_IP /var/www/nexa
# or: export NEXA_SSH=root@YOUR_SERVER_IP && ./deploy/deploy.sh
```

This builds locally and rsyncs `./public` to the server. The site is static, so there is nothing
to run on the server beyond the web server.

> Prefer Nginx? Serve `/var/www/nexa` as the root and add a `try_files $uri $uri/ =404;` location,
> then get a cert with `certbot --nginx -d nexa.uno -d www.nexa.uno`.

---

## Notes

- **Styling — Tailwind CSS v4** (`assets/css/main.css`): the design tokens live in an `@theme` block
  and components (`.btn`, `.card`, `.hero`, …) are built with `@apply`, so the HTML keeps semantic
  class names. The entry uses `@import "tailwindcss" source(none)` — Tailwind does **not** scan the
  templates for utilities (we drive everything through `@apply`), which avoids clashes with our own
  `.container`/`.grid` class names. Preflight is included; we re-assert list markers in `.prose` with
  `list-style: revert` (plain `disc`/`decimal` get stripped by the CSS optimizer as initial values).
  To add a token, add a `--color-*` / `--radius-*` / `--shadow-*` variable in `@theme` and `@apply`
  the generated utility.
- **Adding analytics later** (e.g. Plausible, GA): update `content/*/legal/cookies.md` and add a
  consent banner before setting non-essential cookies (required under Spanish/EU law).
