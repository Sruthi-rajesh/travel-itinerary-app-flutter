# Travel Itinerary App (Flutter) — Melbourne Explorer

A Flutter travel app that helps users **discover places**, **view details**, **save favourites**, and **build a simple itinerary (“Tickets”)** with **Google Maps route opening**.  
Built as a clean, scalable Flutter project using a **HomeShell + Services + Reusable Widgets** structure.

---

## Problem Statement

When exploring a city, users typically jump between multiple apps:
- Google Maps to search places
- Notes/WhatsApp to save recommendations
- Multiple browser tabs to compare options
- No simple way to group nearby places into a quick itinerary

This project solves that by providing a **single workflow**:
1) Discover places  
2) Explore details  
3) Save favourites  
4) Build an itinerary plan (“Tickets”)  
5) Open stops + full route directly in Google Maps  

---

## Key Features

### Home (Discover)
- Location-aware “near you” experience
- Category filtering (e.g., cafes, attractions, parks)
- Recommended + nearby lists

### Place Details
- Rich details for a selected place
- Save / remove favourites

### Search + View All
- Search across all available places
- View all places in a list format

### Favourites (Saved)
- Shows saved places
- Tap to open the Place Details page

### Itinerary (Nearby Plan)
- Builds a nearby plan around a selected place
- Supports refresh/retry if Overpass fails temporarily (common on Web)

### Tickets (Itineraries)
- Demo saved itineraries/tickets (for now)
- Open a ticket to view stops
- Export itinerary text (copy/share)
- Open:
  - Individual stops in Google Maps
  - Full route in Google Maps

### Profile
- Editable user display name
- Shows saved places count
- Clear saved places

---

## App Pages

- **Home**: Discovery + recommendations  
- **Search**: Search places and open details  
- **View All Places**: Browse complete list per section/category  
- **Tourist Details Page**: Place details + favourite toggle  
- **Favourites**: Saved places list  
- **Itinerary Page**: Nearby POIs around a selected place (Food/Shopping)  
- **Tickets Page**: Saved itineraries (demo)  
- **Ticket Details Page**: Stops list + export + route open  
- **Profile Page**: User name edit + saved count + clear  

---

## Architecture

This project follows a simple, scalable separation of concerns:

- `pages/`  
  UI screens (Home, Search, Details, Tickets, Profile)

- `widgets/`  
  Reusable UI components (cards, lists, buttons)

- `services/`  
  Core logic + external integrations:
  - Location fetching + fallback logic  
  - Overpass POI fetch  
  - Favourites store (local state using ValueNotifier)  
  - Maps route opening (url_launcher)

- `models/`  
  Data models used across the app:
  - Place  
  - POI (nearby itinerary item)  
  - Ticket (TicketStop)

---

## Tech Stack

- **Flutter (Dart)**
- **url_launcher** (open Google Maps)
- **Overpass / OpenStreetMap (OSM)** (nearby POI search — subject to rate limits)
- Lightweight state via **ValueNotifier** (favourites)

---

## Google Maps Route Opening

The app uses Google Maps deep links via `url_launcher`.

### Open a single stop
- `https://www.google.com/maps/search/?api=1&query=LAT,LNG`

### Open a full route (with waypoints)
- `https://www.google.com/maps/dir/?api=1&origin=LAT,LNG&destination=LAT,LNG&waypoints=LAT,LNG|LAT,LNG`

On mobile this opens in the Maps app, and on Web it opens in a browser tab.

---

## Known Limitations

- **Overpass 504 / rate limiting** can happen on Flutter Web  
  - The app includes a Refresh/Retry option  
  - Mobile emulator/device is more reliable  
- Tickets are **demo data** for now (can be upgraded to persistent storage)

---

