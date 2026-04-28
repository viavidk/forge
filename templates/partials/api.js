/**
 * api.js — centralt modul til alle REST API-kald.
 * Al fetch-logik samles her. View-filer kalder kun api.*()
 */

const api = (() => {
    const BASE = '';  // sæt base URL hvis API er eksternt, fx 'https://api.example.com'

    function getCsrfToken() {
        const meta = document.querySelector('meta[name="csrf-token"]');
        if (!meta || !meta.content) {
            throw new Error('CSRF token mangler — tilføj <meta name="csrf-token"> til siden');
        }
        return meta.content;
    }

    async function request(method, endpoint, data = null) {
        const options = {
            method,
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': getCsrfToken(),
            },
        };

        if (data !== null) {
            options.body = JSON.stringify(data);
        }

        const res = await fetch(BASE + endpoint, options);

        if (!res.ok) {
            const err = await res.json().catch(() => ({ message: `HTTP ${res.status}` }));
            throw new Error(err.message ?? `HTTP ${res.status}`);
        }

        // 204 No Content har ingen body
        if (res.status === 204) return null;

        return res.json();
    }

    return {
        get:    (endpoint)       => request('GET',    endpoint),
        post:   (endpoint, data) => request('POST',   endpoint, data),
        put:    (endpoint, data) => request('PUT',    endpoint, data),
        delete: (endpoint)       => request('DELETE', endpoint),
    };
})();
