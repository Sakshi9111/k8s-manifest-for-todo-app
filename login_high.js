import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 100 },   // Ramp up to 100 users
    { duration: '2m', target: 500 },    // Ramp up to 500 users
    { duration: '3m', target: 500 },    // Stay at 500 users
    { duration: '30s', target: 1000 },  // Spike to 1000 users
    { duration: '1m', target: 0 },      // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'],
    http_req_failed: ['rate<0.1'],
  },
};

const BASE_URL = 'http://todo.local/'; // Change to your URL

export default function () {
  // Homepage
  let res = http.get(`${BASE_URL}/`);
  check(res, {
    'homepage loaded': (r) => r.status === 200,
  });
  
  // Login attempt
  res = http.post(`${BASE_URL}/login/`, {
    username: 'user_${__VU}_${__ITER}_${randomString(5)}',
    password: 'StrongPass123!',
  });
  check(res, {
    'login attempted': (r) => r.status !== 500,
  });
  
  sleep(0.1); // Very short sleep
}
