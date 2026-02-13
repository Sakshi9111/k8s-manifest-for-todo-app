import http from 'k6/http';
import { check, sleep } from 'k6';
import { randomString } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

export let options = {
  vus: 200,
  iterations: 200,
};

const BASE_URL = 'http://todo.local';

export default function () {
  const jar = http.cookieJar();

  // 1️⃣ GET signup page
  let res = http.get(`${BASE_URL}/accounts/signup/`, {
    jar: jar,
  });

  check(res, {
    'signup page loaded': (r) => r.status === 200,
  });

  let csrfMatch = res.body.match(/name="csrfmiddlewaretoken" value="(.+?)"/);
  if (!csrfMatch) {
    throw new Error('CSRF token not found');
  }

  let csrfToken = csrfMatch[1];

  let username = `user_${__VU}_${__ITER}_${randomString(5)}`;
  let email = `${username}@example.com`;
  let password = 'StrongPass123!';

  let payload = {
    csrfmiddlewaretoken: csrfToken,
    username: username,
    email: email,               // 🔥 REQUIRED
    password1: password,
    password2: password,
  };

  let signupRes = http.post(
    `${BASE_URL}/accounts/signup/`,
    payload,
    {
      jar: jar,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Referer': `${BASE_URL}/accounts/signup/`,
      },
      redirects: 0,
    }
  );

  // ✅ Correct success check for allauth
  check(signupRes, {
    'signup succeeded': (r) =>
      r.status === 302 &&
      r.headers['Location'] &&
      !r.headers['Location'].includes('signup'),
  });

  sleep(0.5);
}

