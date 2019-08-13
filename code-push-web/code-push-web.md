docker run --rm \
--name codepushweb \
-it \
-e 'CODE_PUSH_SERVER_URL=http://10.4.99.4:3000' \
-e 'WEBSITE_HOSTNAME=http://10.4.99.4:3001' \
-p 3001:3001 \
code-push-web-v1 sh