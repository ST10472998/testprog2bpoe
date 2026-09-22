# RaceDay API Endpoint Plan

## Authentication

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/auth/register | Creates a new user account as either an Organiser or a Participant. | None (public) | `{ firstName, lastName, email, password, role }` | 201 Created- user id and role returned. 400 Bad Request- validation failed. 409 Conflict- email already registered |
| POST | /api/auth/login | Authenticates a user and starts a session storing the user id and role. | None (public) | `{ email, password }` | 200 OK- session started, user id and role returned. 401 Unauthorized- invalid credentials |
| POST | /api/auth/logout | Ends the current user's session. | Any (logged in) | None | 200 OK- session cleared |

## User Profile

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/users/me | Returns the logged in user's own profile information. | Any (logged in) | None | 200 OK- user profile object. 401 Unauthorized- no active session |
| PUT | /api/users/me | Updates the logged-in users own profile details. | Any (logged in) | `{ firstName, lastName, email }` | 200 OK- updated profile returned. 400 Bad Request- validation failed. 401 Unauthorized |

## Events

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/events | Lists all upcoming events, visible to anyone browsing the platform. | None (public) | None | 200 OK- array of events |
| GET | /api/events/{id} | Returns full detail for a single event, including its categories. | none (public) | None | 200 OK- event object. 404 Not Found- event does not exist |
| POST | /api/events | Creates a new event owned by the logged in organizer. | Organizer | `{ name, description, eventDate, location, distanceKm, eventType }` | 201 Created- new event returned. 400 Bad Request- validation failed. 403 Forbidden- not an organizer |
| PUT | /api/events/{id} | Updates an event the organizer owns. | organiser | `{ name, description, eventDate, location, distanceKm, eventType }` | 200 OK- updated event. 403 Forbidden- not the owning organizer. 404 Not Found |
| DELETE | /api/events/{id} | Deletes an event the organizer owns. | organizer | None | 200 OK- event removed. 403 Forbidden. 404 Not Found |

## Categories

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| GET | /api/events/{eventId}/categories | Lists all categories available for a specific event. | None (public) | None | 200 OK- array of categories. 404 Not Found- event does not exist |
| POST | /api/events/{eventId}/categories | Adds a new age or distance category to an event the organizer owns. | Organizer | `{ name, minAge, maxAge, distanceKm }` | 201 Created- new category returned. 400 Bad Request. 403 Forbidden |
| PUT | /api/categories/{id} | Updates an existing category. | Organizer | `{ name, minAge, maxAge, distanceKm }` | 200 OK -updated category. 403 Forbidden. 404 Not Found|
| DELETE | /api/categories/{id} | Removes a category from an event. | Organizer | None | 200 OK. 403 Forbidden. 404 Not Found. 409 Conflict- category has existing enrolments |

## Event Enrolments

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/events/{eventId}/enrolments | Enrols the loggedin participant into an event under a chosen category. | Participant | `{ categoryId }` | 201 Created- enrolment record returned. 400 Bad Request-invalid category for this event. 401 Unauthorized. 409 Conflict- already enrolled |
| GET | /api/users/me/enrolments | Returns all events the logged-in participant has enrolled in. | Participant | None | 200 OK- array of enrolments |
| GET | /api/events/{eventId}/enrolments | Returns all participants enrolled in a specific event, for the owning organizer. | Organizer | None | 200 OK- array of enrolments with participant and category detail. 403 Forbidden- not the owning organizer |

## Results

| HTTP Method | Route | Description | Role Required | Request Body | Expected Response |
|---|---|---|---|---|---|
| POST | /api/enrolments/{enrolmentId}/result | Captures the finish time and position for a participants enrolment after the event. | Organizer | `{ finishTime, finishPosition }` | 201 Created- result recorded. 403 Forbidden- not the owning organizer. 404 Not Found- enrolment does not exist. 409 Conflict- result already captured |
| GET | /api/users/me/results | Returns the logged-in participants personal race history across all completed events. | Participant | None | 200 OK- array of results with event name, date, category, finish time and position |
