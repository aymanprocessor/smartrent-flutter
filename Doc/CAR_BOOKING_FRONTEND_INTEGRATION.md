# Car Booking & PayTabs Payment - Frontend Integration Guide

## Overview
This guide provides step-by-step instructions for integrating car booking and PayTabs payment into your frontend application. The API endpoints follow a sequential flow: search cars → preview booking → confirm booking → process payment.

---

## Table of Contents
1. [API Endpoints](#api-endpoints)
2. [Complete Booking Flow](#complete-booking-flow)
3. [Validation Rules Summary](#validation-rules-summary)
4. [PayTabs Payment Integration](#paytabs-payment-integration)
5. [Frontend Examples](#frontend-examples)
6. [Error Handling](#error-handling)
7. [Translations](#translations)

---

## Validation Rules Summary

### Car Booking Confirm Endpoint

**Required Fields (Always Required):**
- `car_id` - Vehicle identifier
- `car_slug` - Vehicle slug
- `mobile` - Contact phone number (Required)
- `fees` - Payment amount
- `token` - Search session token
- `payment` - Payment method ("cash" or "online-payment")

**Conditional Required:**
- `location` - **Required IF** `is_deliver=true`

**Optional Fields:**
- `destination` - Destination location (nullable)
- `distance` - Distance in km (nullable)
- `email` (`credentials`) - Customer email (nullable, optional)
- `rental_days` - Number of rental days (nullable)
- `round_pickup_date` - Return date (nullable)
- `round_pickup_time` - Return time (nullable)
- `message` - Special instructions (nullable)
- `is_deliver` - Delivery required (nullable, default: false)

---

## API Endpoints

### Base URL
```
https://your-domain.com/api/v1/user
```

### Authentication
Most endpoints require Bearer token authentication:
```
Authorization: Bearer {user_token}
```

---

## Complete Booking Flow

### Step 1: Search Cars

**Endpoint:** `POST /car-booking/search`

**Description:** Search for available cars based on criteria.

**Request Parameters:**
```javascript
{
  "car_type": 1,              // Required: Car type ID
  "car_model": 2,             // Required: Car model ID
  "car_area": 1,              // Optional: Car area ID
  "car_year": 2020,           // Optional: Car year
  "pickup_date": "2025-11-20", // Required: Date in YYYY-MM-DD format
  "pickup_time": "10:00",     // Required: Time in HH:MM format (24-hour)
  "round_pickup_date": "2025-11-22", // Optional: Return date
  "round_pickup_time": "14:00"       // Optional: Return time
}
```

**Response on Success (200):**
```javascript
{
  "success": true,
  "message": "Car search successful",
  "data": {
    "token": "unique_booking_token_123", // Save this token for next steps
    "cars": [
      {
        "id": 1,
        "name": "Toyota Corolla",
        "year": 2023,
        "price_per_day": 50,
        "car_model": "Corolla",
        "car_type": "Sedan",
        "car_area": "Downtown",
        "image": "image_url"
      }
    ],
    "data_path": {
      "base_url": "https://your-domain.com",
      "image_path": "path/to/images"
    }
  }
}
```

**Error Response (422):**
```javascript
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "car_type": ["The car type field is required."],
    "pickup_date": ["The pickup date field is required."]
  }
}
```

---

### Step 2: Preview Booking

**Endpoint:** `POST /car-booking/preview`

**Description:** Get booking preview with payment gateways and user details.

**Request Parameters:**
```javascript
{
  "token": "unique_booking_token_123",  // From search step
  "car_id": 5                            // Selected car ID
}
```

**Response on Success (200):**
```javascript
{
  "success": true,
  "message": "Booking data stored in the temporary table",
  "data": {
    "token": "unique_booking_token_123",
    "booking_details": {
      "pickup_date": "2025-11-20",
      "pickup_time": "10:00",
      "round_pickup_date": "2025-11-22",
      "round_pickup_time": "14:00",
      "car_type": 1,
      "car_model": 2
    },
    "booking_currency": "USD",
    "car": {
      "id": 5,
      "name": "Toyota Corolla 2023",
      "vendor_id": 1,
      "price_per_day": 50,
      "image": "url"
    },
    "user": {
      "id": 10,
      "firstname": "John",
      "lastname": "Doe",
      "email": "john@example.com",
      "phone": "+1234567890"
    },
    "payment-type": {
      "online-payment": "online-payment",
      "cash": "cash"
    },
    "payment_gateways": [
      {
        "id": 1,
        "name": "PayTabs",
        "alias": "paytabs",
        "gateway_type": "automatic"
      },
      {
        "id": 2,
        "name": "Stripe",
        "alias": "stripe",
        "gateway_type": "automatic"
      }
    ]
  }
}
```

---

### Step 3: Confirm Booking

**Endpoint:** `POST /car-booking/confirm`

**Description:** Confirm booking details before payment processing.

**Request Parameters:**
```javascript
{
  "token": "unique_booking_token_123",        // From search step
  "car_id": 5,                               // Selected car ID
  "car_slug": "toyota-corolla-2023",         // Car slug
  "destination": "Airport",                  // Optional: Destination
  "distance": 25.5,                          // Optional: Distance in km
  "rental_days": 3,                          // Optional: Number of rental days
  "location": "Downtown Pickup Point",       // Required if is_deliver=true
  "is_deliver": false,                       // Optional: Delivery needed?
  "credentials": "john@example.com",         // Optional: Email
  "mobile": "+1234567890",                   // Required: Phone number
  "round_pickup_date": "2025-11-22",         // Optional: Return date
  "round_pickup_time": "14:00",              // Optional: Return time
  "message": "Please wait at gate",          // Optional: Special instructions
  "fees": 150.00,                            // Required: Total amount to pay
  "payment": "cash",                         // Required: "cash" or "online-payment"
  
  // For online payment:
  "gateway_currency": "usd",                 // Currency alias
  "gateway_type": "automatic",               // "automatic" or "manual"
  
  // For automatic gateway (Stripe, PayTabs, etc.):
  // Include gateway_type = "automatic" and gateway_currency
  
  // For manual gateway:
  // Include gateway_type = "manual" and transaction_id
  "transaction_id": "manual_txn_123"
}
```

**Response on Success (200) - Cash Payment:**
```javascript
{
  "success": true,
  "message": "Booking Successful!",
  "data": []
}
```

**Response on Success (200) - Online Payment (Automatic):**
```javascript
{
  "success": true,
  "message": "Payment gateway response successful",
  "data": {
    "redirect_url": "https://paytabs.com/pay?token=xxx",
    "redirect_links": [],
    "action_type": "redirect",
    "address_info": [],
    "identifier": "booking_identifier_123"
  }
}
```

---

## PayTabs Payment Integration

### PayTabs Create Payment Endpoint

**Endpoint:** `POST /api/paytabs/create-payment`

**Description:** Create a PayTabs payment page for car booking.

**Required Fields:**
```javascript
{
  "cart_id": "booking_123",           // Unique transaction ID
  "cart_amount": 150.50,               // Amount to pay
  "customer_name": "John Doe",         // Customer full name
  "customer_email": "john@example.com", // Customer email
  "customer_phone": "+1234567890"      // Customer phone
}
```

**Optional Fields:**
```javascript
{
  "cart_description": "Car Rental: Toyota Corolla 3 days",
  "customer_street": "123 Main St",
  "customer_city": "New York",
  "customer_state": "NY",
  "customer_country": "USA",           // 3-letter country code
  "customer_zip": "10001",
  "return_url": "https://your-domain.com/booking/success",
  "callback_url": "https://your-domain.com/api/paytabs/callback",
  "transaction_type": "sale",          // sale, auth, register
  "transaction_class": "ecom",         // ecom, recurring, moto
  "payment_method": "all",             // all, credit_card, apple_pay, etc.
  "language": "en",                    // en or ar
  "hide_shipping": true,
  "user_defined": {}
}
```

**Response on Success (200):**
```javascript
{
  "success": true,
  "message": "Payment page created successfully",
  "data": {
    "payment_url": "https://secure.paytabs.sa/pay?token=...",
    "transaction_ref": "123456789"
  }
}
```

**Error Response (400/500):**
```javascript
{
  "success": false,
  "message": "Failed to create payment page",
  "code": "INVALID_AMOUNT"
}
```

---

### PayTabs Callback Handling

**Endpoint:** `POST /api/paytabs/callback`

**Automatic Callback:** PayTabs sends a POST request to your callback URL with:
```javascript
{
  "tran_ref": "transaction_reference",
  "order_id": "your_cart_id",
  "tran_status": "A",    // A = Approved, D = Declined
  "response_code": "000",
  "response_message": "Transaction approved"
}
```

**Your frontend should:**
1. Receive the callback notification
2. Call `/api/paytabs/verify-payment` to confirm status
3. Show success/failure message to user

---

### PayTabs Verify Payment

**Endpoint:** `POST /api/paytabs/verify-payment`

**Request:**
```javascript
{
  "transaction_ref": "123456789"
}
```

**Response:**
```javascript
{
  "success": true,
  "data": {
    "transaction_ref": "123456789",
    "status": "approved",
    "amount": 150.50,
    "currency": "USD",
    "timestamp": "2025-11-13T10:30:00Z"
  }
}
```

---

## Frontend Examples

### JavaScript/Vue.js Example - Complete Flow

```javascript
// Step 1: Search Cars
async function searchCars(searchParams) {
  try {
    const response = await fetch('/api/v1/user/car-booking/search', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${userToken}`
      },
      body: JSON.stringify({
        car_type: searchParams.carType,
        car_model: searchParams.carModel,
        car_area: searchParams.carArea,
        car_year: searchParams.carYear,
        pickup_date: searchParams.pickupDate,
        pickup_time: searchParams.pickupTime,
        round_pickup_date: searchParams.roundPickupDate,
        round_pickup_time: searchParams.roundPickupTime
      })
    });

    const data = await response.json();
    if (data.success) {
      return {
        token: data.data.token,
        cars: data.data.cars
      };
    } else {
      throw new Error(data.message);
    }
  } catch (error) {
    console.error('Search failed:', error);
    return null;
  }
}

// Step 2: Preview Booking
async function previewBooking(token, carId) {
  const response = await fetch('/api/v1/user/car-booking/preview', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${userToken}`
    },
    body: JSON.stringify({
      token: token,
      car_id: carId
    })
  });

  return await response.json();
}

// Step 3: Confirm Booking & Process Payment
async function confirmBooking(bookingData, paymentMethod) {
  const payload = {
    token: bookingData.token,
    car_id: bookingData.carId,
    car_slug: bookingData.carSlug,
    destination: bookingData.destination,
    distance: bookingData.distance,
    rental_days: bookingData.rentalDays,
    is_deliver: bookingData.isDeliver,
    location: bookingData.location,
    credentials: bookingData.email,
    mobile: bookingData.phone,
    round_pickup_date: bookingData.roundPickupDate,
    round_pickup_time: bookingData.roundPickupTime,
    message: bookingData.message,
    fees: bookingData.totalAmount,
    payment: paymentMethod
  };

  // Add payment gateway info for online payments
  if (paymentMethod === 'online-payment') {
    payload.gateway_currency = bookingData.gatewayCurrency;
    payload.gateway_type = bookingData.gatewayType;
  }

  const response = await fetch('/api/v1/user/car-booking/confirm', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${userToken}`
    },
    body: JSON.stringify(payload)
  });

  return await response.json();
}

// Step 4: Create PayTabs Payment
async function createPayTabsPayment(bookingData) {
  const response = await fetch('/api/paytabs/create-payment', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${userToken}`
    },
    body: JSON.stringify({
      cart_id: bookingData.cartId,
      cart_amount: bookingData.totalAmount,
      cart_description: `Car Rental: ${bookingData.carName}`,
      customer_name: bookingData.customerName,
      customer_email: bookingData.customerEmail,
      customer_phone: bookingData.customerPhone,
      language: 'en'
    })
  });

  const data = await response.json();
  if (data.success) {
    // Redirect user to PayTabs payment page
    window.location.href = data.data.payment_url;
  }
  return data;
}

// Usage in your booking component:
async function handleBookingProcess() {
  // Search for cars
  const searchResult = await searchCars({
    carType: 1,
    carModel: 2,
    pickupDate: '2025-11-20',
    pickupTime: '10:00'
  });

  if (!searchResult) return;

  // Preview selected car
  const preview = await previewBooking(searchResult.token, 5);

  // Prepare booking data
  const bookingData = {
    token: searchResult.token,
    carId: 5,
    carSlug: 'toyota-corolla',
    destination: 'Airport',
    distance: 25.5,
    rentalDays: 3,
    email: 'john@example.com',
    phone: '+1234567890',
    totalAmount: 150.00,
    gatewayCurrency: 'usd',
    gatewayType: 'automatic'
  };

  // Confirm booking with PayTabs payment
  const confirmResult = await confirmBooking(bookingData, 'online-payment');

  if (confirmResult.data.redirect_url) {
    // Redirect to PayTabs
    window.location.href = confirmResult.data.redirect_url;
  }
}
```

### React/TypeScript Example

```typescript
import axios from 'axios';

interface SearchParams {
  carType: number;
  carModel: number;
  carArea?: number;
  carYear?: number;
  pickupDate: string;
  pickupTime: string;
  roundPickupDate?: string;
  roundPickupTime?: string;
}

interface Car {
  id: number;
  name: string;
  year: number;
  price_per_day: number;
  image: string;
}

const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL,
  headers: {
    Authorization: `Bearer ${localStorage.getItem('token')}`
  }
});

// Hook to search cars
export const useSearchCars = async (params: SearchParams) => {
  try {
    const { data } = await api.post('/v1/user/car-booking/search', params);
    return data.data;
  } catch (error) {
    console.error('Search failed:', error);
    throw error;
  }
};

// Hook to preview booking
export const usePreviewBooking = async (token: string, carId: number) => {
  try {
    const { data } = await api.post('/v1/user/car-booking/preview', {
      token,
      car_id: carId
    });
    return data.data;
  } catch (error) {
    console.error('Preview failed:', error);
    throw error;
  }
};

// Hook to confirm booking
export const useConfirmBooking = async (bookingData: any) => {
  try {
    const { data } = await api.post('/v1/user/car-booking/confirm', bookingData);
    if (data.data.redirect_url) {
      window.location.href = data.data.redirect_url;
    }
    return data;
  } catch (error) {
    console.error('Confirmation failed:', error);
    throw error;
  }
};
```

---

## Error Handling

### Common HTTP Status Codes

| Status | Meaning | Action |
|--------|---------|--------|
| 200 | Success | Process response data |
| 400 | Bad Request | Check request parameters |
| 401 | Unauthorized | Refresh/renew token |
| 404 | Not Found | Verify IDs and tokens |
| 422 | Validation Error | Review validation errors response |
| 500 | Server Error | Retry or contact support |

### Validation Error Example

```javascript
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "car_type": ["The car type field is required."],
    "pickup_time": ["The pickup time field is required."]
  }
}
```

### Retry Logic (Exponential Backoff)

```javascript
async function fetchWithRetry(url, options, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      const response = await fetch(url, options);
      if (response.ok) return response.json();
      if (response.status === 500 && i < retries - 1) {
        await new Promise(resolve => 
          setTimeout(resolve, Math.pow(2, i) * 1000)
        );
        continue;
      }
      throw new Error(`HTTP ${response.status}`);
    } catch (error) {
      if (i === retries - 1) throw error;
    }
  }
}
```

---

## Translations

The API returns localized messages based on the user's locale. Common keys:

| Key | English | Arabic | Spanish | French |
|-----|---------|--------|---------|--------|
| `Car search successful` | Car search successful | بحث السيارة ناجح | Búsqueda de coche exitosa | Recherche automobile réussie |
| `Booking Successful!` | Booking Successful! | الحجز ناجح | ¡Reserva exitosa! | Réservation réussie! |
| `Something went wrong! Please try again` | Something went wrong! Please try again | حدث خطأ! حاول مرة أخرى | ¡Algo salió mal! Intenta de nuevo | Quelque chose s'est mal passé! Réessayez |

---

## Complete Request/Response Checklist

### Before Sending Request
- [ ] User is authenticated (have valid token)
- [ ] All required fields are provided
- [ ] Data format matches specifications
- [ ] Dates are in YYYY-MM-DD format
- [ ] Times are in HH:MM format (24-hour)
- [ ] Email addresses are valid
- [ ] Phone numbers have country code

### After Receiving Response
- [ ] Check `success` field
- [ ] Handle errors from `errors` field if validation failed
- [ ] Save `token` from search response
- [ ] Store `redirect_url` for payment redirect
- [ ] Verify payment before confirming booking
- [ ] Update UI with response data

---

## Environment Variables

```env
REACT_APP_API_URL=https://your-domain.com/api
REACT_APP_USER_TOKEN=your_user_token_here
REACT_APP_PAYTABS_PUBLIC_KEY=your_paytabs_key
```

---

## Support & Debugging

1. **Enable Debug Mode:** Add `?debug=1` to your requests
2. **Check Browser Console:** Look for network errors
3. **Verify Credentials:** Ensure email/phone are correct
4. **Check Date/Time:** Ensure pickup is in the future
5. **Contact Admin:** For payment gateway issues

---

## Related Documentation

- [PayTabs Integration Guide](./PAYTABS_INTEGRATION_QUICK_REFERENCE.md)
- [API Documentation](./CAR_MODELS_API.md)
- [OTP Login System](./OTP_LOGIN_SYSTEM.md)
- [Payment Gateway Setup](./PAYTABS_SETUP_GUIDE.md)
