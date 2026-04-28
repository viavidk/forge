# /project:deploy

Verify the system is production-ready and output a deployment checklist.

## Steps

1. Run /project:review — abort if any Critical issues exist
2. Verify \`.env\` is not committed (check .gitignore)
3. Verify database/schema.sql is current
$([ "$USE_ROUTER" = "Y" ] && cat << 'HTBLOCK'
4. Verify .htaccess files:
   - Root `.htaccess` blocks /app, /config, /database
   - `public/.htaccess` has correct RewriteBase
HTBLOCK
)
5. Output final checklist:
   - [ ] All secrets in .env, not in source
   - [ ] APP_DEBUG=false in production .env
$([ "$USE_ROUTER" = "Y" ] && echo '   - [ ] Both .htaccess files in place' && echo '   - [ ] RewriteBase matches deployment subpath')
   - [ ] SQLite file writable by web server
   - [ ] Admin password changed from default
   - [ ] composer install run on server
   - [ ] vendor/ is gitignored and not deployed via git
   - [ ] No Critical or Major review findings
