import React from 'react';
import { shallow, mount } from 'enzyme';
import Postgame from 'packs/postgame/Postgame';
import { mock_games_show_request } from '../mock_games_show_request';
import sinon from 'sinon';
// import sinon from './node_modules/sinon/pkg/sinon-esm.js';
 
describe('Postgame component', () => {
  var server;
  
  // beforeEach(function() {
  //   server = sinon.fakeServer.create();
  //   var callback = sinon.fake();
  // });

  // afterEach(function(){
  //   server.restore();
  // });

  // describe('renders with', ()=>{
  //   it('a postgametab with last game displayed', ()=>{
  //     // const sinonSpy = sinon.spy(Postgame.prototype, 'hooligan')
  //     // const postgame = render(<Postgame mock_games_show_request/>)
  //     debugger
  //   });
  // });
  
  it('retrieveCardsForPostGame on componentDidMount', async () => {
    // let server = sinon.fakeServer.create();
    
    const PostgameComponent = await shallow(<Postgame />);
    debugger

    
    //  PostgameComponent.instance().componentDidMount = jest.fn();
    //  PostgameComponent.update();
    //  PostgameComponent.instance().handleNameInput('BoB');
    //  expect(PostgameComponent.instance().searchDish).toBeCalledWith('BoB');
  })
});
