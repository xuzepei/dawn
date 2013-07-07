
function handle()
{
	var candidateErrors = document.getElementsByTagName("candidateError");
    
    var i = 0
    for(i = 0; i < candidateErrors.length; i++)
    {
        var temp = candidateErrors[i];
        
        var index;
        if(0 == i)
            index = "A";
        else if(1 == i)
            index = "B";
        else if(2 == i)
            index = "C";
        else if(3 == i)
            index = "D";
        else if(4 == i)
            index = "E";
        else if(5 == i)
            index = "F";
        else if(6 == i)
            index = "G";
        
        temp.innerHTML = "<span class=\"questionAnswersSpan\"><label>" + index + "</label> <strong>" + temp.innerHTML + "</strong></span>";
        
    }

}