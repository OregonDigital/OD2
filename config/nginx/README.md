# README

These files are `nginx` formatted rewrite rules for translating old URL
patterns to OD1 and OD2 style URL patterns.

### `od2_od1_rewrites.conf`

Translates ContentDM URL patterns to OD1 URL patterns

### `od2_rewrites.conf`

Translates OD1 URL patterns to OD2 URL patterns

**OD1 Works to OD2 Works**

- `^/catalog/oregondigital:(.*)$ https://oregondigital.org/concern/images/$1;`
- `^/catalog/oregondigital-(.*)$ https://oregondigital.org/concern/images/$1;`

**OD1 Works within a Set to the OD2 Work**
**OD1 Sets to OD2 Collections**
**OD1 downloads patterns to OD2 downloads patterns**
**OD1 BookReader Viewer image requests to the OD2 Work
**ContentDM and OD1 Sets to OD2 Sets**
**ContentDM and OD1 Info Pages to OD2 Info Pages**
