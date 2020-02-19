FROM erlang:22-alpine AS build
RUN apk --update add git gcc g++ libstdc++
RUN mkdir /work
WORKDIR /work
COPY rebar.config rebar.lock ./
RUN rebar3 compile
COPY src/ src/
RUN rebar3 compile

FROM erlang:22-alpine
RUN mkdir -p /app/ebin /app/config
RUN chown daemon /app/config
WORKDIR /app
COPY --from=build /work/_build/default/lib/*/ebin/* ebin/
COPY --from=build /work/_build/default/lib/*/priv/* priv/
COPY --from=build /usr/lib/libgcc_s.so* /usr/lib/libstdc++.so* /usr/lib/
USER daemon
EXPOSE 3000
CMD \
  if [ -z "$RIB_BACKEND" ]; then \
    RIB_BACKEND=https://api.github.com; \
  fi && \
  echo "[{rib, [{port, 3000}, {backend, \"$RIB_BACKEND\"}]}]." \
    > config/demo.config && \
  erl -pa ebin -noshell -config config/demo -s rib start
