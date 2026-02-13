import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 20 },   // warm up
    { duration: '2m', target: 50 },   // load
    { duration: '2m', target: 100 },  // stress
    { duration: '1m', target: 0 },    // cool down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // SLO
    http_req_failed: ['rate<0.01'],   // <1% errors
  },
};

const BASE_URL = 'http://todo.local';

export default function () {
  // 1️⃣ Login page
  let res = http.get(`${BASE_URL}/login/`);
  check(res, { 'login page loaded': r => r.status === 200 });

  // Extract CSRF token (Django)
  let csrf = res.html('input[name=csrfmiddlewaretoken]').attr('value');

  // 2️⃣ Login
  res = http.post(`${BASE_URL}/login/`, {
    username: 'testuser',
    password: 'testpassword',
    csrfmiddlewaretoken: csrf,
  }, {
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      Referer: `${BASE_URL}/login/`,
    },
  });

  check(res, { 'logged in': r => r.status === 302 || r.status === 200 });

  // 3️⃣ Create todo
  res = http.post(`${BASE_URL}/todos/create/`, {
    title: `todo-${__VU}-${__ITER}`,
  });

  check(res, { 'todo created': r => r.status === 200 || r.status === 302 });

  // 4️⃣ List todos
  res = http.get(`${BASE_URL}/todos/`);
  check(res, { 'todos listed': r => r.status === 200 });

  sleep(1);
}
