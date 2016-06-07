import React from 'react';
import ReactDOM from 'react-dom';
import { Router, browserHistory } from 'react-router';
import routes from './routes';

ReactDOM.render(
  <Router history={broserHistory} routes={routes} />,
  doucment.getElementById('app')
);

