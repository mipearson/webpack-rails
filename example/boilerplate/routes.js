import React from 'react';
import { Route } from 'react-router';
import App from './containers/App';
import NoMatch from './components/NoMatch';

export default (
  <Route>
    <Route path="/" component={App} />
    <Route path="*" status={404} component={NoMatch}/>
  </Route>
)

