Unified CrystalGrimoire System Design
1. User Profile & Collection Data Management
Design a unified Profile that stores personal data (birth date/time/location and subscription tier) and links to the user’s Crystal Collection (stored stones). In code, StorageService saves the birth-chart JSON and subscription tier locally
GitHub
GitHub
, and CollectionService persists the crystal collection and usage logs (in shared prefs or backend) as CollectionEntry records
GitHub
GitHub
. We propose a combined model: a backend UserProfile record (or local equivalent) with fields birthDate, birthTime, birthLocation, latitude/longitude, and tier. The user’s owned crystals are stored as a list of CollectionEntry objects (each with crystal data, acquisition info, etc.)
GitHub
GitHub
. Subscription tier (e.g. free/premium/pro/founders) is saved in StorageService and drives feature access
GitHub
GitHub
. In practice, Profile data is read/written via StorageService (e.g. saveBirthChart, saveSubscriptionTier)
GitHub
GitHub
, and the Collection service handles syncing crystals (with optional backend sync stubs)
GitHub
GitHub
. This unifies all user data in one logical schema: profile (personal info + astrological data) plus collection (owned crystals and metadata).
2. LLM-Powered Personalization Flow
The LLM prompts should incorporate the user’s crystal collection and horoscope context dynamically. For example, the Metaphysical Guidance screen builds a userProfile JSON containing collection statistics, favorite/recent crystals, and spiritual preferences
GitHub
, then sends it to an LLM-based API (via BackendService.getPersonalizedGuidance) along with the chosen guidance type and any user query
GitHub
GitHub
. This enables the model to tailor advice to “your” actual collection. Similarly, for crystal identification or healing prompts, the birth-chart’s getSpiritualContext() can be added to the prompt context. The BirthChart.getSpiritualContext() method packages sun, moon, ascendant signs, element dominance, and recommended crystals into a map
GitHub
. The backend attaches this astrological context to requests
GitHub
, allowing the LLM to weave in zodiac info (e.g. “As an Aries with strong Fire element…”). In sum, each LLM prompt should include: (a) user profile (crystals owned, goals), (b) astrological context, and (c) any specific query, so responses feel deeply personal. (The existing code already demonstrates this pattern in the Metaphysical Guidance flow
GitHub
GitHub
.)
3. Horoscope & Astrology Integration
For daily horoscopes or natal chart insights, we can use a free astrology API or fall back to AI generation. The Beta code attempts to use FreeAstrologyAPI endpoints (/planets and /houses) to compute a detailed birth chart
GitHub
GitHub
. If the API fails (or no free API is available), the app falls back to simplified in-code calculations (BirthChart.calculate, using day-of-year for sun sign, etc.)
GitHub
. In practice we would register a free key for a service like this if possible. However, if no reliable free API exists, we can have the LLM generate daily horoscopes from structured birth data. For example, an LLM prompt could say “Generate today’s horoscope for a [SunSign] with Moon in [MoonSign] and Ascendant in [Ascendant]…” using the birth-date/time data. The code’s BirthChart already provides enough zodiac info for LLMs to craft a horoscope: sunSign, moonSign, ascendant, elements, etc.
GitHub
. Given these inputs, a modern LLM could generate meaningful horoscope text. (In summary, prefer using a free astrology API when practical
GitHub
, but otherwise rely on LLM-driven composition from the stored chart data.)
4. Feature Interconnections
All major features should reference the shared profile/collection and complement each other. For example:
Journal ↔ Astrology & Crystals: When creating a journal entry, include that day’s moon phase (via a MoonPhaseCalculator) or astrological snapshot. Entries could list which owned crystal was used and any horoscope insights. The code hints at this by showing a “Recent Journal Entries” card built from recent CollectionEntry items
GitHub
; we would replace that with actual user-written entries that mention crystals and moon data.
Healing ↔ Collection: A healing session prompt should filter to crystals the user owns. E.g. “For your heart chakra healing, consider [Crystal1] and [Crystal2] that you have in your collection.” The CollectionService can return crystals by purpose (e.g. getCrystalsByPurpose("healing")
GitHub
 or by chakra
GitHub
. The LLM prompt can enumerate those owned crystals as options.
Moon Ritual ↔ Astrology & Collection: The Moon Ritual Planner uses current moon phase data (e.g. “Full Moon” etc.) with recommended crystals for that phase (hardcoded in the UI dictionary)
GitHub
GitHub
. We would enhance it by highlighting which of those phase-appropriate crystals the user actually owns (from the collection DB). That is, if the “Full Moon” calls for Clear Quartz and Selenite, highlight “(you have Selenite in your shelf)” or suggest alternatives from their collection.
Metaphysical Guidance ↔ All Modules: Guidance should naturally draw on Journal and Ritual data. For instance, if the user journaled about anxiety, the advisor might suggest a specific crystal from the collection. Or if the calendar shows a scheduled ritual, guidance could reference it (“Since you have a new Moon ritual tonight, you might use [CrystalX] which you recently added”). The backend already includes contextual flavor (e.g. inclusion of owned crystals)
GitHub
GitHub
.
Collection ↔ Others: The crystal collection is the hub. Whenever any feature needs a crystal recommendation, it checks the collection first. For example, a healing feature can recommend only owned stones, or a ritual planner lists only those the user has. Conversely, other modules can prompt adding new crystals: e.g. the Guidance screen might say “consider adding Labradorite (you can add it via Collection).”
These interactions can be summarized as follows:
Feature	Integrates With	Example Interaction
Journal	Astrology, Collection	Tags each entry with moon phase/astrological mood; suggests journaling about crystals used that day.
Healing	Collection, Guidance	Recommends healing crystals from user’s own collection by chakra/purpose; logs usage in Journal.
Moon Ritual	Astrology, Collection	Shows next full/new moon, suggests rituals + crystals (filtering to owned); syncs planned rituals.
Metaphysical Guidance	Journal, Astrology, Collection	Uses userProfile (fav/recent crystals, birth chart) to answer questions; references journaled moods.
Crystal Collection	All features	Serves as source of truth for what crystals user has; used by Guidance, Ritual, Healing prompts.
No matter the entry point, each screen pulls from the shared data models (UserProfile with birthChart, Subscription; CollectionEntries with crystals) so that all features can cross-reference. This ensures, e.g., a healing prompt never suggests an unknown crystal, and daily horoscopes tie back to the user’s sign.
5. Unified Flow & Architecture
We envision a hub-style UI with shared navigation (e.g. a bottom nav bar or drawer) linking: Home (dashboard), Journal, Moon Rituals, Guidance, Collection, Profile/Settings. Each screen accesses the same underlying data. For example:
Home/Dashboard could show today’s horoscope snippet, current moon phase (using MoonPhaseCalculator
GitHub
), and a “Crystal of the Day” pulled from collection stats
GitHub
.
Profile/Settings lets the user enter birth info (date, time, location) stored via StorageService.saveBirthChart
GitHub
, and view/change subscription. The birth chart screen (if present) computes/requests the natal chart using the AstrologyService (or the simplified fallback)
GitHub
.
Collection Screen lists owned crystals (via CollectionService.collection), and allows CRUD operations (as in Beta code).
Journal Screen allows writing notes; on save it could attach context (date, moon phase, perhaps select crystals used from a picker) and store entries in a local DB linked to crystals. It might also show insights (e.g. a chart of mood changes vs. crystal use using CollectionStats).
Moon Ritual Screen (the planner) presents lunar calendar info and ritual templates
GitHub
GitHub
, pulling from user settings (e.g. what crystals they want to include).
Guidance Screen (LLM chat) uses all the above context. It builds its prompt with the stored userProfile JSON
GitHub
 and any new user query
GitHub
, then calls the backend LLM endpoint (like /spiritual/guidance) which returns a personalized response.
Under the hood, shared data models ensure consistency: the BirthChart (with its toJson) and CollectionEntry (with toJson/fromJson) are the common objects passed between frontend and backend
GitHub
GitHub
. The StorageService and CollectionService handle local persistence and sync (caching, SharedPreferences)
GitHub
GitHub
. By structuring data this way, navigation between modules is seamless: e.g. the user taps a crystal in Collection, sees its detail, then with one tap starts a healing session using that crystal (the crystal’s ID and properties are already in the collection model). Overall, the unified architecture ties together: StorageService (profile and subscription data) ➔ CollectionService (owned crystals & logs) ➔ Services (AstrologyService, OpenAIService/BackendService) for computation and LLM prompts ➔ Screens (UI for Journal, Rituals, Guidance, etc.) that consume this data. This ensures every feature “speaks the same language” (shared models) and can reference the user’s personal data and crystals to create an immersive, interconnected experience. Sources: The above design builds on code structures in CrystalGrimoireBeta2 and alpha-v1, e.g. StorageService for profile data
GitHub
GitHub
, CollectionService models
GitHub
GitHub
, AstrologyService use of a free API
GitHub
, and how the Metaphysical Guidance screen composes prompts with user data
GitHub
GitHub
. All integration logic follows these examples.