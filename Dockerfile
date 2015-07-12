FROM tutum/buildstep
ENV PORT 80
EXPOSE 80
CMD ["/start", "web"]