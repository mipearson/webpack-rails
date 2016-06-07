import { createStore, compose, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';

// import the root reducer
import rootReducer from './reducers/index';

const createStoreWithMiddleware = compose (
  applyMiddleware(thunk),
  window.devToolsExtension ? window.devToolsExtension() : f => f
)(createStore)

const store = createStoreWithMiddleware(rootReducer);


if(module.hot) {
  module.hot.accept('./reducers/',() => {
    const nextRootReducer = require('./reducers/index').default;
    store.replaceReducer(nextRootReducer);
  });
}

export default store;

