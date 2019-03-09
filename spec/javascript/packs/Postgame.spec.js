import React from 'react';
import { shallow, mount } from 'enzyme';
import Postgame from 'packs/postgame/Postgame';
import { mock_games_show_request_for_last_postgame } from '../fixtures/mock_games_show_request_for_last_postgame';
import { mock_games_show_request_for_second_to_last_postgame } from '../fixtures/mock_games_show_request_for_second_to_last_postgame';
import { postgames_state_with_two_loaded_games } from '../fixtures/postgames_state_with_two_loaded_games';
// import sinon from 'sinon';
// import sinon from './node_modules/sinon/pkg/sinon-esm.js';

describe('Postgame component', () => {
  // Unit test methods
  describe('#retrieveCardsForPostgame', () => {
    describe('A new postgame is requested', async () => { 
      describe('with id index -1 (only should happen on componentDidMount and server will return last postgames info  )', async ()=>{
        let PostgameComponent;
        let mock_getNewPostgameinfoRequest;
        let postgame_component_instance;
  
        beforeAll(async () => {
          PostgameComponent = shallow(<Postgame />);
          mock_getNewPostgameinfoRequest = jest.fn(function(id) { return Promise.resolve({'data': mock_games_show_request_for_last_postgame }); });
          postgame_component_instance = PostgameComponent.instance();
          postgame_component_instance.getNewPostgameInfoRequest = mock_getNewPostgameinfoRequest;
          await PostgameComponent.instance().retrieveCardsForPostgame(-1);
        });
  
        it('api request made with correct id', async () => {  
          expect(mock_getNewPostgameinfoRequest.mock.calls[0][0]).toEqual(-1);
        });
        
        it('should have populated state with contents of new postgame info', async () => {  
          expect(PostgameComponent.state()).toMatchObject(mock_games_show_request_for_last_postgame);
        });
      });

      describe('with a new index of (ie 6), after the initial loaded, latest postgame', async () => {
        let PostgameComponent;
        let mock_getNewPostgameinfoRequest;
        let postgame_component_instance;

        beforeAll(async () => {
          PostgameComponent = shallow(<Postgame />);
          expect(PostgameComponent.state()).not.toMatchObject(mock_games_show_request_for_last_postgame)          

          postgame_component_instance = PostgameComponent.instance();
          mock_getNewPostgameinfoRequest = jest.fn(function(id) { return Promise.resolve({'data': mock_games_show_request_for_second_to_last_postgame }); });
          postgame_component_instance.getNewPostgameInfoRequest = mock_getNewPostgameinfoRequest;
          await postgame_component_instance.retrieveCardsForPostgame(6);
        })

        it('should have passed argument 6', async () => {  
          expect(mock_getNewPostgameinfoRequest.mock.calls[0][0]).toEqual(6);
        });

        it('should have populated state with contents of the new postgame info', async () => {  
          expect(PostgameComponent.state()).toMatchObject(postgames_state_with_two_loaded_games);
        });
      });
    });

    describe('An existing postgame is requested', async () => { 
      describe('if the id of the current postgame_info is passed, api not called and state not updated if postgame requested is the one on the screen' , async () => {
        let PostgameComponent;
        let mock_getNewPostgameinfoRequest;
        let postgame_component_instance;
        
        beforeAll(async () => {
          PostgameComponent = shallow(<Postgame />);

          let response_1 = function(id) { return Promise.resolve({'data': mock_games_show_request_for_last_postgame }); }
          let response_2 = function(id) { return Promise.resolve({'data': mock_games_show_request_for_second_to_last_postgame}); }

          mock_getNewPostgameinfoRequest = jest.fn().mockImplementationOnce(response_1).mockImplementationOnce(response_2);

          postgame_component_instance = PostgameComponent.instance()
          postgame_component_instance.getNewPostgameInfoRequest = mock_getNewPostgameinfoRequest;
          await postgame_component_instance.retrieveCardsForPostgame(7);
          await postgame_component_instance.retrieveCardsForPostgame(6);
          debugger
          expect(PostgameComponent.state()).toMatchObject(postgames_state_with_two_loaded_games)
          mock_getNewPostgameinfoRequest = jest.fn().mockImplementationOnce(response_1);

          await postgame_component_instance.retrieveCardsForPostgame(7);
        })

        it('expect that the api was not called when switching to see the slideshow of an already loaded postgame', async () => {  
          expect(mock_getNewPostgameinfoRequest).not.toBeCalled;
        });

        fit('should just switch the state reference to be looking at old reference', async () => {  
          expect(PostgameComponent.state()).toMatchObject(postgames_state_with_two_loaded_games);
        });
      });

      it('if the id of an already loaded postgame_info is passed, then nothing should happen', async () => {
        // postgames_state_with_two_loaded_games["PostGameTab"]["current_postgame_id"] = 6;
        // api call is not called

        // state is not changed
      })
    })



    // it('-1 returns the same result as passing the latest user\'s postgame_id', async ()=>{
    // })


    it('#selectTab', ()=>{})
    it('#retrieveOutOfGameCards', ()=>{})

    it('passes correct params to PostGameTab',()=>{})
    it('passes correct params to OutOfGameCardUploadTab',()=>{})
  })


  // BDD
  describe('when a user lands on the postgame page', () => {
    it('PostGameTab rendered with correct properties', () => {

    })

    it('OutOfGameCardUploadTab not rendered', () => {

    })
  })

  describe('user clicks OutOfGamesTab', () => {
    it('OutOfGamesTab is rendered with correct params', () => {

    })

    describe('then clicks PostGameTab to get back to main screen', ()=> {

    })
  })

  

  
  it('when user clicks NEW postgame, then SHOULD fetch new info from server called', () => {
    //getNewPostgameInfoRequest
  })

  it('when user clicks an ALREADY LOADED postgame, then should NOT fetch new info from server called', () => {
    //getNewPostgameInfoRequest
  })

});
